#!/bin/bash
# AgentSystems Installer Script
# Installs Docker, pipx, and the AgentSystems SDK
# Supports macOS and Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform detection
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}       AgentSystems Platform Installer        ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Function to print colored messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if running with sudo when needed
check_sudo() {
    if [[ $EUID -ne 0 ]] && [[ "$1" == "required" ]]; then
        print_error "This operation requires sudo privileges"
        echo "Please run: curl -fsSL https://raw.githubusercontent.com/agentsystems/agentsystems/main/install.sh | sudo sh"
        exit 1
    fi
}

# Check OS compatibility
check_os() {
    case "$OS" in
        Linux*)
            print_status "Detected Linux ($ARCH)"
            ;;
        Darwin*)
            print_status "Detected macOS ($ARCH)"
            ;;
        *)
            print_error "Unsupported operating system: $OS"
            echo "This installer supports Linux and macOS only"
            exit 1
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker
install_docker() {
    print_info "Checking Docker installation..."
    
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_status "Docker is already installed (version $DOCKER_VERSION)"
        
        # Check if Docker daemon is running
        if ! docker info >/dev/null 2>&1; then
            print_warning "Docker is installed but not running"
            if [[ "$OS" == "Darwin" ]]; then
                print_info "Please start Docker Desktop"
            else
                print_info "Please start the Docker daemon: sudo systemctl start docker"
            fi
            exit 1
        fi
    else
        print_warning "Docker is not installed"
        
        if [[ "$OS" == "Darwin" ]]; then
            print_info "Please install Docker Desktop from:"
            echo "  https://www.docker.com/products/docker-desktop/"
            echo ""
            echo "After installation, run this script again."
            exit 1
        else
            # Linux installation
            print_info "Installing Docker..."
            
            # Use Docker's official install script
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            rm get-docker.sh
            
            # Add current user to docker group
            if [[ $EUID -ne 0 ]]; then
                sudo usermod -aG docker $USER
                print_warning "Added $USER to docker group. Please log out and back in for this to take effect."
            fi
            
            # Start Docker
            sudo systemctl start docker
            sudo systemctl enable docker
            
            print_status "Docker installed successfully"
        fi
    fi
}

# Install pipx
install_pipx() {
    print_info "Checking pipx installation..."
    
    if command_exists pipx; then
        PIPX_VERSION=$(pipx --version | cut -d' ' -f1)
        print_status "pipx is already installed (version $PIPX_VERSION)"
    else
        print_warning "pipx is not installed"
        print_info "Installing pipx..."
        
        # Check for Python 3
        if ! command_exists python3; then
            print_error "Python 3 is required but not installed"
            if [[ "$OS" == "Darwin" ]]; then
                print_info "Install Python 3 using Homebrew: brew install python3"
            else
                print_info "Install Python 3 using your package manager"
            fi
            exit 1
        fi
        
        # Install pipx based on OS
        if [[ "$OS" == "Darwin" ]]; then
            if command_exists brew; then
                brew install pipx
                pipx ensurepath
            else
                # Fallback to pip
                python3 -m pip install --user pipx
                python3 -m pipx ensurepath
            fi
        else
            # Linux installation
            if command_exists apt-get; then
                sudo apt-get update
                sudo apt-get install -y pipx
            elif command_exists dnf; then
                sudo dnf install -y pipx
            elif command_exists pacman; then
                sudo pacman -S --noconfirm python-pipx
            else
                # Fallback to pip
                python3 -m pip install --user pipx
                python3 -m pipx ensurepath
            fi
        fi
        
        print_status "pipx installed successfully"
        
        # Update PATH for current session
        export PATH="$PATH:$HOME/.local/bin"
    fi
}

# Install AgentSystems SDK
install_agentsystems() {
    print_info "Installing AgentSystems SDK..."
    
    # Check if already installed
    if pipx list | grep -q "agentsystems-sdk"; then
        print_info "AgentSystems SDK is already installed, upgrading..."
        pipx upgrade agentsystems-sdk
    else
        pipx install agentsystems-sdk
    fi
    
    # Verify installation
    if command_exists agentsystems; then
        SDK_VERSION=$(agentsystems --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_status "AgentSystems SDK installed successfully (version $SDK_VERSION)"
    else
        print_error "AgentSystems SDK installation failed"
        exit 1
    fi
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}    Installation Complete! 🎉                 ${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo ""
    echo "1. Initialize your AgentSystems deployment:"
    echo -e "   ${GREEN}agentsystems init${NC}"
    echo ""
    echo "2. Start the platform:"
    echo -e "   ${GREEN}cd agent-platform-deployments${NC}"
    echo -e "   ${GREEN}agentsystems up${NC}"
    echo ""
    echo "3. Access the platform:"
    echo "   • API Gateway: http://localhost:18080"
    echo "   • Langfuse: http://localhost:3010"
    echo ""
    echo -e "${BLUE}Documentation:${NC} https://github.com/agentsystems/agentsystems"
    echo -e "${BLUE}SDK Reference:${NC} https://github.com/agentsystems/agentsystems-sdk"
    echo ""
    
    # Check if PATH needs updating
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        print_warning "Add $HOME/.local/bin to your PATH by adding this to your shell profile:"
        echo '    export PATH="$PATH:$HOME/.local/bin"'
        echo ""
    fi
    
    # Docker group reminder for Linux
    if [[ "$OS" == "Linux" ]] && ! groups | grep -q docker; then
        print_warning "You may need to log out and back in for Docker group changes to take effect"
    fi
}

# Main installation flow
main() {
    check_os
    
    echo ""
    print_info "Starting installation process..."
    echo ""
    
    # Step 1: Docker
    install_docker
    echo ""
    
    # Step 2: pipx
    install_pipx
    echo ""
    
    # Step 3: AgentSystems SDK
    install_agentsystems
    
    # Done!
    print_next_steps
}

# Run main function
main