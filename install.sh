#!/usr/bin/env bash
# bootstrap_agentsystems.sh
# Idempotent setup for pipx, Docker Engine, and agentsystems-sdk
# Works for both admin and non-admin users.
# Flags:
#   -y | --yes        : unattended (auto-confirm)
#   --interactive     : force prompts even via `curl | sh`
#   --pip-only        : never attempt Homebrew; install pipx via pip --user
#   --no-docker       : skip Docker steps entirely

# Strict mode; degrade gracefully outside bash
if [ -n "$BASH_VERSION" ]; then
  set -euo pipefail
else
  set -eu
fi

# --- UX helpers ---
red=""; plain=""
if command -v tput >/dev/null 2>&1; then
  red="$(tput bold 2>/dev/null && tput setaf 1 2>/dev/null || :)"
  plain="$(tput sgr0 2>/dev/null || :)"
fi
status() { echo ">>> $*" >&2; }
warn()   { echo "${red}WARNING:${plain} $*" >&2; }
die()    { echo "${red}ERROR:${plain} $*" >&2; exit 1; }
have()   { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"

# --- Flags ---
AUTO_CONFIRM=false
FORCE_INTERACTIVE=false
PIP_ONLY=false
NO_DOCKER=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes) AUTO_CONFIRM=true ;;
    --interactive) FORCE_INTERACTIVE=true ;;
    --pip-only) PIP_ONLY=true ;;
    --no-docker) NO_DOCKER=true ;;
  esac
done

# --- POSIX-safe confirm (supports curl | sh via /dev/tty) ---
confirm() {
  msg=$1
  if $AUTO_CONFIRM; then status "$msg -> auto-confirmed"; return 0; fi
  if $FORCE_INTERACTIVE && [ -r /dev/tty ]; then
    printf '%s [y/N]: ' "$msg" >/dev/tty; IFS= read -r ans </dev/tty
  elif [ -t 0 ]; then
    printf '%s [y/N]: ' "$msg" >&2; IFS= read -r ans
  elif [ -r /dev/tty ]; then
    printf '%s [y/N]: ' "$msg" >/dev/tty; IFS= read -r ans </dev/tty
  else
    warn "No TTY available for prompts. Re-run with --yes or --interactive."; return 1
  fi
  case $ans in [Yy]|[Yy][Ee][Ss]) return 0 ;; *) return 1 ;; esac
}

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
is_admin_macos() { [ "$OS" = "Darwin" ] && /usr/sbin/dseditgroup -o checkmember -m "$(id -un)" admin 2>/dev/null | grep -qi "yes"; }
have_passwordless_sudo() { sudo -n true 2>/dev/null; }

# --- Sudo guard ---
require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    if $AUTO_CONFIRM; then die "This step needs sudo. Run 'sudo -v' first or re-run interactively."; fi
    status "Requesting sudo privileges..."; sudo -v || die "Could not obtain sudo privileges."
  fi
}

# --- Python 3.11+ requirement helpers ---
python_meets_311() {
  python3 - <<'PY' >/dev/null 2>&1
import sys; raise SystemExit(0 if sys.version_info >= (3,11) else 1)
PY
}
python_version_str() {
  python3 - <<'PY' 2>/dev/null || true
import sys; print(".".join(map(str, sys.version_info[:3])))
PY
}

# --- System Requirements Check (includes Python>=3.11) ---
check_requirements() {
  status "Checking system requirements..."

  if [ "$OS" = "Darwin" ]; then
    status "✅ macOS detected."
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    status "✅ Ubuntu Linux detected."
    is_wsl && warn "WSL detected. Prefer Docker Desktop for Windows with WSL integration."
  elif [ "$OS" = "Linux" ]; then
    warn "Non-Ubuntu Linux detected. Docker installation may require manual setup."
  else
    die "Unsupported OS: $OS. This script supports macOS and Ubuntu Linux."
  fi

  if ! have python3; then
    die "Python 3 is required but not found. Please install Python 3.11+ and re-run."
  fi
  if ! python_meets_311; then
    cur="$(python_version_str)"; cur="${cur:-unknown}"
    warn "Python ${cur} detected. agentsystems-sdk requires Python 3.11+."
    status "Upgrade options:"
    if [ "$OS" = "Darwin" ]; then
      echo "  • Download installer (no admin needed): https://www.python.org/downloads/"
      have brew && echo "  • Or via Homebrew (admin): brew install python@3.12"
      have pyenv && echo "  • Or via pyenv (user-space): pyenv install 3.11.9 && pyenv global 3.11.9"
      echo "  • If Python came from Xcode CLT, you may update dev tools: xcode-select --install"
    else
      echo "  • Install a system Python 3.11+ using your distro’s package manager (or ask IT)"
    fi
    die "Please upgrade Python to 3.11+ and re-run this script."
  fi

  status "✅ Python $(python_version_str) meets the 3.11+ requirement."
  status "✅ System requirements verified."
}

# --- Compute per-user script bin (handles macOS ~/Library/Python/x.y/bin) ---
user_base_bin() {
  python3 - <<'PY'
import site, pathlib
print(str(pathlib.Path(site.USER_BASE) / "bin"))
PY
}

# --- PATH persistence (update only files that already exist + ~/.profile) ---
add_path_persist() {
  USER_BASE_BIN="$(user_base_bin)"
  add_line_local='export PATH="$HOME/.local/bin:$PATH"'
  add_line_userbase="export PATH=\"$USER_BASE_BIN:\$PATH\""

  add_to_file() {
    rc="$1"  # POSIX: no 'local'
    [ -f "$rc" ] || return 0
    if ! grep -Fq '$HOME/.local/bin' "$rc" 2>/dev/null; then
      echo "$add_line_local" >> "$rc"
      status "Added PATH to $rc (~/.local/bin)"
    fi
    if ! grep -Fq "$USER_BASE_BIN" "$rc" 2>/dev/null; then
      echo "$add_line_userbase" >> "$rc"
      status "Added PATH to $rc ($USER_BASE_BIN)"
    fi
  }

  case "$(basename "${SHELL:-}")" in
    zsh)  add_to_file "$HOME/.zprofile"; add_to_file "$HOME/.zshrc" ;;
    bash) add_to_file "$HOME/.bash_profile"; add_to_file "$HOME/.bashrc" ;;
    *)    : ;;
  esac
  add_to_file "$HOME/.profile"

  export PATH="$HOME/.local/bin:$USER_BASE_BIN:$PATH"
}

# --- Preflight plan ---
preflight_plan() {
  status "Preflight checks…"
  if [ "$OS" = "Darwin" ]; then
    if $PIP_ONLY; then
      warn "macOS: Using --pip-only → pipx will be installed in user space (~/.local & user base bin)."
    elif have brew; then
      status "macOS: Homebrew present."
    elif is_admin_macos; then
      status "macOS: Admin rights detected → can install Homebrew if approved."
    else
      warn "macOS: No admin rights → cannot install Homebrew. Falling back to pipx user install; we'll persist PATH."
    fi
  fi
  if [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    if $NO_DOCKER; then
      warn "Ubuntu: --no-docker provided → Docker steps will be skipped."
    elif have_passwordless_sudo; then
      status "Ubuntu: sudo available → can install Docker Engine."
    else
      warn "Ubuntu: sudo not available → cannot install Docker Engine. Use --no-docker to skip."
    fi
  fi
}

# --- pipx ---
ensure_pipx() {
  if have pipx; then
    status "✅ pipx found: $(pipx --version 2>/dev/null || true)"
    return 0
  fi

  status "pipx not detected."
  if ! confirm "Proceed with installing pipx?"; then
    warn "Skipped pipx installation."; return 0
  fi

  if [ "$OS" = "Darwin" ]; then
    if $PIP_ONLY; then
      warn "Using --pip-only: installing pipx in user space."
      python3 -m pip install --user pipx
    elif have brew; then
      brew install pipx
    else
      if is_admin_macos; then
        warn "Homebrew not found. Installing Homebrew is recommended for reliable pipx setup."
        if confirm "Install Homebrew now? (Requires admin password)"; then
          if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            [ -f "/opt/homebrew/bin/brew" ] && export PATH="/opt/homebrew/bin:$PATH"
            [ -f "/usr/local/bin/brew" ]   && export PATH="/usr/local/bin:$PATH"
            if have brew; then brew install pipx; else warn "Brew installed but not on PATH; falling back to pip user install."; python3 -m pip install --user pipx; fi
          else
            warn "Homebrew installation failed/denied. Falling back to pip user install for pipx."
            python3 -m pip install --user pipx
          fi
        else
          warn "Skipping Homebrew. Falling back to pip user install for pipx."
          python3 -m pip install --user pipx
        fi
      else
        warn "No admin rights on macOS: proceeding with pip user install for pipx."
        python3 -m pip install --user pipx
      fi
    fi
  elif [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release; then
    if have_passwordless_sudo; then
      require_sudo
      if ! (sudo apt-get update -y && sudo apt-get install -y pipx); then
        python3 -m pip install --user pipx
      fi
    else
      warn "No sudo available → installing pipx in user space."
      python3 -m pip install --user pipx
    fi
  else
    python3 -m pip install --user pipx
  fi

  # Make per-user installs usable now and in future shells
  python3 -m pipx ensurepath || true
  add_path_persist

  status "✅ pipx installed."
}

# --- Docker ---
engine_running() { docker info >/dev/null 2>&1; }
docker_status() {
  if have docker; then
    status "✅ Docker CLI found: $(docker --version 2>/dev/null || true)"
    if engine_running; then status "✅ Docker Engine is running."; return 0
    else warn "Docker CLI present but Engine not running."; return 2; fi
  else
    warn "Docker CLI not found."; return 1
  fi
}

install_docker_macos() {
  status "Docker not detected."
  status "Docker Desktop is the recommended install method."
  if confirm "Open the Docker Desktop download page now?"; then
    if $AUTO_CONFIRM; then status "Docker Desktop download: https://www.docker.com/products/docker-desktop/"
    else (have open && open "https://www.docker.com/products/docker-desktop/") || true; fi
  fi
  if ! confirm "After installing, ensure Docker Desktop is running. Continue?"; then
    die "User aborted before Docker Desktop was confirmed running."
  fi
  have docker || die "Docker CLI not in PATH. Open a new terminal and retry."
  count=0; while [ $count -lt 90 ]; do engine_running && break; sleep 2; count=$((count+1)); done
  engine_running || die "Docker Engine not running. Start Docker Desktop and retry."

  # Fix for Docker Compose plugin detection on macOS (GitHub docker/compose#8986)
  # Create symlink so Docker can find the compose plugin
  if [ -d "/Applications/Docker.app/Contents/Resources/cli-plugins" ] && [ ! -e "/usr/local/lib/docker/cli-plugins" ]; then
    status "Creating Docker Compose plugin symlink for better compatibility..."
    require_sudo
    sudo mkdir -p /usr/local/lib/docker
    sudo ln -s /Applications/Docker.app/Contents/Resources/cli-plugins /usr/local/lib/docker/cli-plugins
  fi

  status "✅ Docker Engine running (macOS)."
}

install_docker_ubuntu_packages() {
  status "Configuring Docker APT repo and installing Engine..."
  export DEBIAN_FRONTEND=noninteractive
  require_sudo
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
  fi
  codename="$(lsb_release -cs)"
  list_file=/etc/apt/sources.list.d/docker.list
  if ! grep -qs 'download\.docker\.com/linux/ubuntu' "$list_file" 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${codename} stable" | sudo tee "$list_file" >/dev/null
  fi
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

ensure_docker() {
  if $NO_DOCKER; then warn "Skipping Docker installation due to --no-docker."; return 0; fi
  st=0; docker_status || st=$?
  case "$st" in 0) return 0 ;; 1) ;; 2) ;; esac

  if ! confirm "Proceed with Docker setup?"; then warn "Skipped Docker setup."; return 0; fi

  if [ "$OS" = "Darwin" ]; then
    if have docker && ! engine_running; then
      if ! confirm "Start Docker Desktop now and continue?"; then die "User declined to start Docker Desktop."; fi
      engine_running || die "Docker Engine still not running."; status "✅ Docker Engine started (macOS)."; return 0
    fi
    install_docker_macos; return 0
  fi

  if [ "$OS" = "Linux" ] && grep -qi ubuntu /etc/os-release; then
    if have docker && ! engine_running; then
      if confirm "Start and enable the Docker service now?"; then
        require_sudo; sudo systemctl enable --now docker || die "Failed to start docker service."
        engine_running || { warn "Docker installed but not accessible to current user."; warn "Try: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"; die "Then re-run this script."; }
        status "✅ Docker Engine started (Ubuntu)."
      else
        die "User declined to start Docker service."
      fi
      return 0
    fi
    if ! have docker; then
      status "Installing Docker Engine packages via APT..."
      install_docker_ubuntu_packages
      require_sudo; sudo systemctl enable --now docker
      engine_running || { warn "Docker installed but not accessible to current user."; warn "Try: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"; die "Then re-run this script."; }
      status "✅ Docker Engine installed and running (Ubuntu)."
      if [ "$(id -un)" != "root" ] && ! id -nG "$(id -un)" 2>/dev/null | grep -qw docker; then
        warn "To run docker without sudo: sudo usermod -aG docker \"$(id -un)\" && newgrp docker"
      fi
      return 0
    fi
  fi

  if [ "$OS" = "Linux" ]; then die "Unsupported Linux for automatic Docker setup. Install Docker manually."; fi
}

# --- Helper to run pipx (handles both command and module installations) ---
run_pipx() {
  # Try standalone pipx command first (Homebrew, apt, etc.)
  if have pipx; then
    pipx "$@"
  # Fall back to Python module invocation (pip --user installs)
  elif python3 -m pipx --version >/dev/null 2>&1; then
    python3 -m pipx "$@"
  else
    return 1
  fi
}

# --- agentsystems-sdk via pipx ---
ensure_agentsystems_sdk() {
  status "Ensuring latest agentsystems-sdk via pipx."
  export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$(user_base_bin):$PATH"

  # Verify pipx is available using our helper
  if ! run_pipx --version >/dev/null 2>&1; then
    die "pipx not found. Open a new terminal (PATH refresh) or run: export PATH=\"\$HOME/.local/bin:$(user_base_bin):\$PATH\""
  fi

  if confirm "Proceed with installing/upgrading agentsystems-sdk?"; then
    if run_pipx list --json 2>/dev/null | grep -q '"package":"agentsystems-sdk"'; then
      run_pipx upgrade agentsystems-sdk
    else
      run_pipx install agentsystems-sdk
    fi
    status "✅ agentsystems-sdk is up to date."
  else
    warn "Skipped agentsystems-sdk installation/upgrade."
  fi
}

# --- Main ---
status "=== Bootstrapping: pipx • Docker • agentsystems-sdk ==="
check_requirements
preflight_plan
if ! confirm "Proceed with the installation plan above?"; then die "Aborted by user."; fi
echo
ensure_pipx
echo
ensure_docker
echo
ensure_agentsystems_sdk

# --- Next Steps / PATH guidance ---
print_next_steps() {
  echo
  status "🎉 Installation Complete!"
  echo

  # Find agentsystems even if not on PATH yet
  agentsystems_found=""
  for path in \
    "$HOME/.local/bin/agentsystems" \
    "/opt/homebrew/bin/agentsystems" \
    "/usr/local/bin/agentsystems"; do
    [ -f "$path" ] && { agentsystems_found="$path"; break; }
  done

  if ! have agentsystems && [ -n "$agentsystems_found" ]; then
    warn "agentsystems is installed but not in your current PATH."
    status "If you ran this via 'curl | sh', your shell cannot inherit PATH changes from the script."
    status "Run this in your current shell to use it immediately:"
    path_dir="$(dirname "$agentsystems_found")"
    echo "  export PATH=\"$path_dir:\$PATH\""
    echo
    status "For future sessions, PATH updates were added to your shell startup files. 'agentsystems' will be available in new terminals."
  fi

  status "Next Steps:"
  echo "  1. Initialize: agentsystems init"
  echo "  2. Start platform: cd agent-platform-deployments && agentsystems up"
  echo "  3. Access UI: http://localhost:3001"
  echo
  status "Tip: To use it immediately in THIS shell (non-admin path):"
  echo "  export PATH=\"\$HOME/.local/bin:$(user_base_bin):\$PATH\""
  echo
  status "Documentation: https://github.com/agentsystems/agentsystems"
}

print_next_steps