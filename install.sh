#!/usr/bin/env bash
# bootstrap_agentsystems.sh
# Idempotent setup for pipx, Docker Engine, and agentsystems-sdk
# Interactive by default; headless/CI via --yes or when not attached to a TTY.

# Use strict mode; degrade gracefully outside bash
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
die()    { echo "${red}ERROR:${plain} $*" >&2; exit 1; }
have()   { command -v "$1" >/dev/null 2>&1; }

# --- Flags ---
AUTO_CONFIRM=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes) AUTO_CONFIRM=true ;;
  esac
done
# Auto-confirm in non-interactive contexts (no stdin or no stdout TTY)
if [ ! -t 0 ] || [ ! -t 1 ]; then
  AUTO_CONFIRM=true
fi

# POSIX-safe confirm (no bashisms)
confirm() {
  msg=$1
  if $AUTO_CONFIRM; then
    status "$msg -> auto-confirmed"
    return 0
  fi
  printf '%s [y/N]: ' "$msg" >&2
  IFS= read -r ans
  case $ans in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

OS="$(uname -s)"
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

# --- Sudo guard (avoid hanging prompts in headless mode) ---
require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    if $AUTO_CONFIRM; then
      die "This step needs sudo. Start a sudo session first (e.g., run 'sudo -v')."
    else
      status "Requesting sudo privileges..."
      sudo -v || die "Could not obtain sudo privileges."
    fi
  fi
}

# --- System Requirements Check ---
check_requirements() {
  status "Checking system requirements..."

  if [ "$OS" = "Darwin" ]; then
    status "✅ macOS detected."
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    status "✅ Ubuntu Linux detected."
    if is_wsl; then
      warn "WSL detected. Recommended: Docker Desktop for Windows with WSL integration."
    fi
  elif [ "$OS" = "Linux" ]; then
    warn "Non-Ubuntu Linux detected. Docker installation may require manual setup."
  else
    die "Unsupported OS: $OS. This script supports macOS and Ubuntu Linux."
  fi

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
      warn "Homebrew not found. Installing Homebrew is recommended for reliable pipx setup on macOS."
      if confirm "Install Homebrew now? (Recommended)"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -f "/opt/homebrew/bin/brew" ]; then
          export PATH="/opt/homebrew/bin:$PATH"
        elif [ -f "/usr/local/bin/brew" ]; then
          export PATH="/usr/local/bin:$PATH"
        fi
        have brew || die "Homebrew installation failed. Please install manually and retry."
        brew install pipx
      else
        warn "Installing pipx without Homebrew may require manual PATH configuration."
        python3 -m pip install --user pipx
      fi
    fi
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release; then
    require_sudo
    if ! (sudo apt-get update -y && sudo apt-get install -y pipx); then
      python3 -m pip install --user pipx
    fi
  else
    python3 -m pip install --user pipx
  fi

  # Detect if pipx came from Homebrew (so we can skip ensurepath)
  used_brew=false
  if [ "$OS" = "Darwin" ] && have brew && brew list --formula 2>/dev/null | grep -qx pipx; then
    used_brew=true
  fi

  if [ "$used_brew" = false ]; then
    python3 -m pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"

    # Ensure PATH is updated for new shells (write once per file)
    add_to_shell_config() {
      shell_config="$1"
      path_line='export PATH="$HOME/.local/bin:$PATH"'
      if [ -f "$shell_config" ]; then
        if ! grep -q "\$HOME/.local/bin" "$shell_config" 2>/dev/null; then
          echo "$path_line" >> "$shell_config"
          status "Added PATH to $shell_config"
        fi
      fi
    }
    add_to_shell_config "$HOME/.bashrc"
    add_to_shell_config "$HOME/.zshrc"
    add_to_shell_config "$HOME/.profile"
  fi

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
    if $AUTO_CONFIRM; then
      status "Docker Desktop download: https://www.docker.com/products/docker-desktop/"
    else
      (have open && open "https://www.docker.com/products/docker-desktop/") || true
    fi
  fi
  if ! confirm "After installing, ensure Docker Desktop is running. Continue?"; then
    die "User aborted before Docker Desktop was confirmed running."
  fi
  have docker || die "Docker CLI not in PATH. Open a new terminal and retry."
  count=0
  while [ $count -lt 90 ]; do
    if engine_running; then break; fi
    sleep 2
    count=$((count + 1))
  done
  engine_running || die "Docker Engine not running. Start Docker Desktop and retry."
  status "✅ Docker Engine running (macOS)."
}

install_docker_ubuntu_packages() {
  status "Configuring Docker APT repo and installing Engine..."
  export DEBIAN_FRONTEND=noninteractive
  require_sudo

  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  # Idempotent keyring setup
  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  # Idempotent sources list setup
  codename="$(lsb_release -cs)"
  list_file=/etc/apt/sources.list.d/docker.list
  if ! grep -qs 'download\.docker\.com/linux/ubuntu' "$list_file" 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${codename} stable" | sudo tee "$list_file" >/dev/null
  fi

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

ensure_docker() {
  st=0
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
        require_sudo
        sudo systemctl enable --now docker || die "Failed to start docker service."
        if ! engine_running; then
          warn "Docker is installed but not accessible to the current user."
          warn "Try: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"
          die "Then re-run this script."
        fi
        status "✅ Docker Engine started (Ubuntu)."
      else
        die "User declined to start Docker service."
      fi
      return 0
    fi
    if confirm "Install Docker Engine packages via APT now?"; then
      install_docker_ubuntu_packages
      require_sudo
      sudo systemctl enable --now docker
      if ! engine_running; then
        warn "Docker is installed but not accessible to the current user."
        warn "Try: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"
        die "Then re-run this script."
      fi
      status "✅ Docker Engine installed and running (Ubuntu)."
      if ! id -nG "$(id -un)" 2>/dev/null | grep -qw docker; then
        warn "To run docker without sudo: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"
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

  # Ensure pipx is available - check Homebrew and user install locations
  if ! have pipx; then
    if [ "$OS" = "Darwin" ] && have brew; then
      if [ -f "/opt/homebrew/bin/pipx" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
      elif [ -f "/usr/local/bin/pipx" ]; then
        export PATH="/usr/local/bin:$PATH"
      fi
    fi
    export PATH="$HOME/.local/bin:$PATH"
    have pipx || die "pipx not found. Please open a new terminal and retry."
  fi

  if confirm "Proceed with installing/upgrading agentsystems-sdk?"; then
    if pipx list --json 2>/dev/null | grep -q '"package":"agentsystems-sdk"'; then
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

  if ! have agentsystems; then
    agentsystems_found=""
    for path in \
      "$HOME/.local/bin/agentsystems" \
      "/opt/homebrew/bin/agentsystems" \
      "/usr/local/bin/agentsystems"; do
      if [ -f "$path" ]; then
        agentsystems_found="$path"
        break
      fi
    done

    if [ -n "$agentsystems_found" ]; then
      warn "agentsystems is installed but not in your current PATH."
      status "Run this command to update your PATH for this session:"
      path_dir="$(dirname "$agentsystems_found")"
      echo "  export PATH=\"$path_dir:\$PATH\""
      echo
      status "Or open a new terminal/SSH session for the PATH to be automatically updated."
      echo
    fi
  fi

  status "Next Steps:"
  echo "  1. Initialize: agentsystems init"
  echo "  2. Start platform: cd agent-platform-deployments && agentsystems up"
  echo "  3. Access UI: http://localhost:3001"
  echo
  status "Documentation: https://github.com/agentsystems/agentsystems"
}

print_next_steps