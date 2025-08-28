#!/usr/bin/env bash
# bootstrap_agentsystems.sh
# Idempotent setup for pipx, Docker Engine, and agentsystems-sdk
# Supports interactive mode (default) or non-interactive with --yes/-y

# For maximum compatibility, we'll just remove the bash-specific options when not in bash
if [ -n "$BASH_VERSION" ]; then
  set -euo pipefail
else
  set -eu
fi

# --- UX helpers ---
red=""
plain=""
if command -v tput >/dev/null 2>&1; then
  red="$(tput bold 2>/dev/null && tput setaf 1 2>/dev/null || :)"
  plain="$(tput sgr0 2>/dev/null || :)"
fi
status() { echo ">>> $*" >&2; }
warn()   { echo "${red}WARNING:${plain} $*" >&2; }
die()    { echo "${red}ERROR:${plain} $*"; exit 1; }
have()   { command -v "$1" >/dev/null 2>&1; }

# --- Flags ---
AUTO_CONFIRM=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes) AUTO_CONFIRM=true ;;
  esac
done

# Auto-confirm if piped (no interactive terminal available)
if [ ! -t 0 ]; then
  AUTO_CONFIRM=true
fi

confirm() {
  local msg="$1"
  if $AUTO_CONFIRM; then
    status "$msg -> auto-confirmed"
    return 0
  fi
  
  read -r -p "$msg [y/N]: " ans
  case "${ans}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

OS="$(uname -s)"

# --- System Requirements Check ---
check_requirements() {
  status "Checking system requirements..."
  
  # OS already detected as $OS - reuse existing logic patterns
  if [ "$OS" = "Darwin" ]; then
    status "✅ macOS detected."
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    status "✅ Ubuntu Linux detected."
  elif [ "$OS" = "Linux" ]; then
    warn "Non-Ubuntu Linux detected. Docker installation may require manual setup."
  else
    die "Unsupported OS: $OS. This script supports macOS and Ubuntu Linux."
  fi
  
  # Reuse existing have() function
  if ! have python3; then
    die "Python 3 is required but not found. Please install Python 3.8 or later."
  fi
  
  status "✅ System requirements verified."
}

# --- pipx ---
ensure_pipx() {
  if have pipx; then
    status "✅ pipx found: $(pipx --version 2>/dev/null || true)"
    return 0
  fi

  status "pipx not detected."
  if ! confirm "Proceed with installing pipx?"; then
    warn "Skipped pipx installation."
    return 0
  fi

  if [ "$OS" = "Darwin" ]; then
    if have brew; then
      brew install pipx
    else
      if ! have python3; then die "python3 not found; install Xcode CLT or Python first."; fi
      python3 -m pip install --user pipx
    fi
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release; then
    if ! (sudo apt-get update -y && sudo apt-get install -y pipx); then
      python3 -m pip install --user pipx
    fi
  else
    python3 -m pip install --user pipx
  fi

  python3 -m pipx ensurepath || true
  
  # Ensure PATH is updated for current session
  export PATH="$HOME/.local/bin:$PATH"
  
  # Ensure PATH is updated for new shells
  add_to_shell_config() {
    local shell_config="$1"
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    
    if [ -f "$shell_config" ]; then
      # Check if PATH is already configured
      if ! grep -q '$HOME/.local/bin' "$shell_config" 2>/dev/null; then
        echo "$path_line" >> "$shell_config"
        status "Added PATH to $shell_config"
      fi
    fi
  }
  
  # Update common shell configs
  add_to_shell_config "$HOME/.bashrc"
  add_to_shell_config "$HOME/.zshrc"
  add_to_shell_config "$HOME/.profile"
  
  status "✅ pipx installed."
}

# --- Docker ---
engine_running() { docker info >/dev/null 2>&1; }

docker_status() {
  if have docker; then
    status "✅ Docker CLI found: $(docker --version 2>/dev/null || true)"
    if engine_running; then
      status "✅ Docker Engine is running."
      return 0
    else
      warn "Docker CLI present but Engine not running."
      return 2
    fi
  else
    warn "Docker CLI not found."
    return 1
  fi
}

install_docker_macos() {
  status "Docker not detected."
  status "Docker Desktop is the recommended install method."
  if confirm "Open the Docker Desktop download page now?"; then
    (have open && open "https://www.docker.com/products/docker-desktop/") || true
  fi
  if ! confirm "After installing, ensure Docker Desktop is running. Continue?"; then
    die "User aborted before Docker Desktop was confirmed running."
  fi
  have docker || die "Docker CLI not in PATH. Open a new terminal and retry."
  for _ in {1..90}; do engine_running && break || sleep 2; done
  engine_running || die "Docker Engine not running. Start Docker Desktop and retry."
  status "✅ Docker Engine running (macOS)."
}

install_docker_ubuntu_packages() {
  status "Configuring Docker APT repo and installing Engine..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  codename="$(lsb_release -cs)"
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${codename} stable
EOF

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

ensure_docker() {
  local st=0
  docker_status || st=$?

  case "$st" in
    0) return 0 ;;   # CLI + Engine running
    1) ;;            # Not installed
    2) ;;            # CLI yes, Engine no
  esac

  if ! confirm "Proceed with Docker setup?"; then
    warn "Skipped Docker setup."
    return 0
  fi

  if [ "$OS" = "Darwin" ]; then
    if have docker && ! engine_running; then
      if ! confirm "Start Docker Desktop now and continue?"; then
        die "User declined to start Docker Desktop."
      fi
      engine_running || die "Docker Engine still not running."
      status "✅ Docker Engine started (macOS)."
      return 0
    fi
    install_docker_macos
    return 0
  fi

  if [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release; then
    if have docker && ! engine_running; then
      if confirm "Start and enable the Docker service now?"; then
        sudo systemctl enable --now docker || die "Failed to start docker service."
        engine_running || die "Docker Engine still not running."
        status "✅ Docker Engine started (Ubuntu)."
      else
        die "User declined to start Docker service."
      fi
      return 0
    fi
    if confirm "Install Docker Engine packages via APT now?"; then
      install_docker_ubuntu_packages
      sudo systemctl enable --now docker
      engine_running || die "Docker Engine failed to start after installation."
      status "✅ Docker Engine installed and running (Ubuntu)."
      if have id && ! id -nG "$USER" 2>/dev/null | grep -qw docker; then
        warn "To run docker without sudo: sudo usermod -aG docker \"$USER\" && re-login"
      fi
    else
      die "User declined Docker installation."
    fi
    return 0
  fi

  die "Unsupported OS for automatic Docker setup: $OS"
}

# --- agentsystems-sdk ---
ensure_agentsystems_sdk() {
  status "Ensuring latest agentsystems-sdk via pipx."
  
  # Ensure pipx bin directory is in PATH
  export PATH="$HOME/.local/bin:$PATH"
  
  if confirm "Proceed with installing/upgrading agentsystems-sdk?"; then
    # Try upgrade first, fall back to install if not already installed
    if pipx list | grep -q agentsystems-sdk; then
      pipx upgrade agentsystems-sdk
    else
      pipx install agentsystems-sdk
    fi
    status "✅ agentsystems-sdk is up to date."
  else
    warn "Skipped agentsystems-sdk installation/upgrade."
  fi
}

# --- Main ---
status "=== Bootstrapping: pipx • Docker • agentsystems-sdk ==="
check_requirements
echo
ensure_pipx
echo
ensure_docker
echo
ensure_agentsystems_sdk

# --- Next Steps ---
print_next_steps() {
    echo
    status "🎉 Installation Complete!"
    echo
    
    # Check if agentsystems command is available
    if ! have agentsystems && [ -f "$HOME/.local/bin/agentsystems" ]; then
        warn "agentsystems is installed but not in your current PATH."
        status "Run this command to update your PATH for this session:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo
        status "Or open a new terminal/SSH session for the PATH to be automatically updated."
        echo
    fi
    
    status "Next Steps:"
    echo "  1. Initialize: agentsystems init"
    echo "  2. Start platform: cd agent-platform-deployments && agentsystems up"
    echo "  3. Access UI: http://localhost:3001"
    echo
    status "Documentation: https://github.com/agentsystems/agentsystems"
}

print_next_steps