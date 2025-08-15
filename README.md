# AgentSystems

> 🚀 **The open platform for deploying and managing AI agents at scale**

AgentSystems provides enterprise-ready infrastructure for running autonomous AI agents in production. Build, deploy, and manage fleets of intelligent agents with confidence.

## ✨ Features

- **🎯 Agent Orchestration** - Deploy and manage multiple AI agents with a unified control plane
- **🔌 Framework Agnostic** - Works with LangChain, CrewAI, AutoGPT, and custom agents
- **📊 Built-in Observability** - Integrated Langfuse for tracing, monitoring, and debugging
- **🐳 Container-Native** - All agents run in isolated Docker containers for security and scalability
- **🔐 Enterprise Security** - Secure credential management, network isolation, and audit logging
- **⚡ Quick Start** - Get running in under 5 minutes with our automated installer

## 🚀 Quick Start

### Automatic Installation (Recommended)

**Linux & macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/agentsystems/agentsystems/main/install.sh | sh
```

This installer will:
1. Check and install Docker if needed
2. Check and install pipx if needed
3. Install the AgentSystems SDK
4. Provide next steps to get you started

### Manual Installation

If you prefer to install manually or are on Windows:

1. **Install Docker**
   - [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows)
   - [Docker Engine](https://docs.docker.com/engine/install/) (Linux)

2. **Install pipx**
   ```bash
   # macOS with Homebrew
   brew install pipx
   pipx ensurepath
   
   # Linux/WSL
   python3 -m pip install --user pipx
   python3 -m pipx ensurepath
   ```

3. **Install AgentSystems SDK**
   ```bash
   pipx install agentsystems-sdk
   ```

## 📖 Getting Started

### 1. Initialize Your Deployment

```bash
agentsystems init
```

This interactive command will:
- Create a new deployment directory
- Set up your configuration files
- Configure Langfuse for observability
- Pull required Docker images

### 2. Start the Platform

```bash
cd agent-platform-deployments
agentsystems up
```

Your platform is now running! Access:
- **API Gateway**: http://localhost:18080
- **Langfuse UI**: http://localhost:3010

### 3. Deploy Your First Agent

Create an agent configuration in `agentsystems-config.yml`:

```yaml
agents:
  - name: my-assistant
    image: ghcr.io/agentsystems/examples/assistant-agent:latest
    environment:
      OPENAI_API_KEY: ${OPENAI_API_KEY}
    capabilities:
      - web-search
      - code-execution
```

Deploy the agent:
```bash
agentsystems up
```

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client Apps   │────▶│  API Gateway │────▶│   Agents    │
└─────────────────┘     └──────────────┘     └─────────────┘
                               │                     │
                               ▼                     ▼
                        ┌──────────────┐     ┌─────────────┐
                        │   Langfuse   │     │   Docker    │
                        │ Observability│     │  Containers │
                        └──────────────┘     └─────────────┘
```

## 📦 Core Components

### [AgentSystems SDK](https://github.com/agentsystems/agentsystems-sdk)
Command-line tool for managing deployments, written in Python.

```bash
agentsystems --help
```

### [Agent Control Plane](https://github.com/agentsystems/agent-control-plane)
Core runtime that orchestrates agents, handles routing, and manages lifecycle.

### [Agent Template](https://github.com/agentsystems/agent-template)
Cookiecutter template for creating new agents with best practices built-in.

```bash
pipx install cookiecutter
cookiecutter gh:agentsystems/agent-template
```

## 📚 Documentation

- **[Quick Start Guide](docs/quickstart.md)** - Get up and running in 5 minutes
- **[Agent Development](docs/agent-development.md)** - Build custom agents
- **[Configuration Reference](docs/configuration.md)** - Complete config options
- **[API Reference](docs/api.md)** - REST API documentation
- **[Deployment Guide](docs/deployment.md)** - Production deployment best practices

## 🧪 Examples

Check out our [examples repository](https://github.com/agentsystems/examples) for:
- LangChain RAG Agent
- CrewAI Research Team
- AutoGPT Clone
- Custom Python Agent
- Multi-Agent Workflows

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Clone the repositories
git clone https://github.com/agentsystems/agentsystems
git clone https://github.com/agentsystems/agentsystems-sdk
git clone https://github.com/agentsystems/agent-control-plane

# Install SDK in development mode
cd agentsystems-sdk
pipx install --editable .

# Run tests
./scripts/test.sh
```

## 📊 Roadmap

- [x] Core platform and SDK
- [x] Langfuse integration
- [x] Docker-based isolation
- [ ] Kubernetes operator
- [ ] Agent marketplace
- [ ] Web UI dashboard
- [ ] Multi-region support
- [ ] Agent versioning and rollbacks

## 💬 Community

- **GitHub Discussions**: [Ask questions and share ideas](https://github.com/agentsystems/agentsystems/discussions)
- **Discord**: [Join our community](https://discord.gg/agentsystems)
- **Twitter**: [@agentsystems](https://twitter.com/agentsystems)

## 📄 License

AgentSystems is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Built with amazing open source projects:
- [Docker](https://docker.com) - Container runtime
- [Langfuse](https://langfuse.com) - LLM observability
- [FastAPI](https://fastapi.tiangolo.com) - API framework
- [Typer](https://typer.tiangolo.com) - CLI framework

---

<p align="center">
  Made with ❤️ by the AgentSystems team
</p>

<p align="center">
  <a href="https://github.com/agentsystems/agentsystems/stargazers">⭐ Star us on GitHub</a>
</p>
