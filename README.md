# AgentSystems

> [!NOTE]
> **Public Pre-Release** - We're building AgentSystems in the open! Official public launch coming soon.
> Join our [Discord](https://discord.com/invite/bXgbDNpj) for updates, feedback, and access to new features.

## The Open Runtime for AI Agents

**Run third-party and custom agents with a zero-trust–inspired approach.** Deploy community and commercial AI agents within infrastructure you control—from laptop to data center. Access an emerging ecosystem of specialized agents, executing in your environment. Compatible with OpenAI, Anthropic, Bedrock, and local models via Ollama. Single-command installer (macOS/Linux).

## The Third Way for AI Agents

**Traditional approaches:**
- Send your data to AI services (data leaves your control)
- Build custom agents from scratch (complex and time-consuming)

**The AgentSystems approach:**
- 🏠 **Run on Your Infrastructure** - Deploy where you control: laptop, server, cloud, or air-gapped networks
- 🔄 **Agent Portability** - Agents built for AgentSystems can run anywhere the platform runs
- 🔌 **Provider Flexibility** - Configure connections to OpenAI, Anthropic, Bedrock, or local models
- 🚀 **Quick Deployment** - One-line install gets you started
- 📦 **Container Isolation** - Each agent runs in its own Docker container with configurable access

## Key Capabilities

- **Local Data Processing** - Process data on your infrastructure
- **Agent Ecosystem** - Discover and share community and commercial agents
- **Container Isolation** - Each agent runs in a separate Docker container
- **Mix & Match AI Providers** - Use OpenAI, Anthropic, Bedrock, Ollama, and more
- **Thread-Scoped Execution** - Each request gets its own storage and context
- **Built-in Egress Control** - Configure URL access for agents
- **Cryptographic Audit Trail** - Hash-chained logs for operation tracking
- **Smart Resource Management** - Agents start when needed, stop when idle
- **Multi-Registry Federation** - Pull agents from multiple sources simultaneously

## Quick Start (MacOS and Linux)

```bash
curl -fsSL https://github.com/agentsystems/agentsystems/releases/latest/download/install.sh | sh
```

## Platform Components

| Repository | Purpose | Technology |
|------------|---------|------------|
| [agent-control-plane](https://github.com/agentsystems/agent-control-plane) | Gateway & orchestration | FastAPI, PostgreSQL, Docker |
| [agentsystems-sdk](https://github.com/agentsystems/agentsystems-sdk) | CLI deployment tool | Python, Docker Compose |
| [agentsystems-ui](https://github.com/agentsystems/agentsystems-ui) | Web interface | React, TypeScript |
| [agentsystems-toolkit](https://github.com/agentsystems/agentsystems-toolkit) | Agent development | Python, LangChain |
| [agent-template](https://github.com/agentsystems/agent-template) | Reference agent | FastAPI, LangGraph |

## How It Works

```mermaid
graph LR
    A[Your App] -->|Request| B[Gateway :18080]
    B --> C[Agent Container]
    C -->|Results| A
    B --> D[Audit Logs]
    C --> E[Local Processing]
    B --> F[Egress Proxy]
    F --> G[Allowed URLs]
```

The gateway discovers agents via Docker labels, routes requests, applies configured policies, and logs operations. Each agent runs in a Docker container with configurable network access.

## Key Features

### Security Features
- Docker container deployment for agents
- Configurable network egress filtering
- Audit logging capabilities (PostgreSQL)
- Thread-scoped file processing

### Agent Management  
- Auto-discovery of Docker containers
- Lazy startup and idle timeout
- Multi-registry support (Docker Hub, Harbor, ECR)
- Agent switching capabilities

### Developer Experience
- Simple FastAPI contract for agents
- Model provider abstraction (`get_model()`)
- Built-in file upload/download handling
- Progress tracking and async operations

## Building Your First Agent

[Full agent development guide →](https://docs.agentsystems.ai/agents)

## Platform Overview

AgentSystems is infrastructure for running AI agents wherever you want - your laptop, home server, or enterprise data center. It handles the complex bits (isolation, orchestration, networking) so you can focus on building cool stuff.

The platform provides container orchestration specifically designed for AI agents, with isolation features, audit trails, and an emerging ecosystem where developers share specialized agents (both free and commercial).

## Documentation

- **[Getting Started Guide](https://docs.agentsystems.ai/quickstart)** - Quick deployment guide
- **[Architecture Overview](https://docs.agentsystems.ai/architecture)** - Deep dive into system design
- **[Security Model](https://docs.agentsystems.ai/security)** - Isolation and audit details
- **[Agent Development](https://docs.agentsystems.ai/agents)** - Build custom agents
- **[API Reference](https://docs.agentsystems.ai/api)** - Complete endpoint documentation
- **[Enterprise Deployment](https://docs.agentsystems.ai/enterprise)** - Production configurations

## Example Use Cases

**For Individuals & Developers:**

AgentSystems is for any individual or developer who wants to control their AI infrastructure.

- **Personal AI Assistant** - Run your own assistants without sending data to big tech
- **Local Development** - Test and debug AI agents without cloud costs
- **Content Creation** - Process your creative work locally
- **Home Automation** - Connect agents to your smart home

**For Businesses & Organizations:**

AgentSystems is for any organization that wants to benefit from AI agents but doesn't want to share sensitive data or deal with infrastructure complexity. Examples include:

- **Startups** - Build AI products without infrastructure overhead
- **Healthcare** - Process patient data in controlled environments
- **Financial Services** - Analyze sensitive financial data locally
- **Legal Firms** - Review confidential documents locally

## Contributing

We're building this in the open and need help from:
- **Agent developers** - Build specialized agents to share or sell
- **Security researchers** - Help us harden the isolation
- **DevOps professionals** - Improve deployment and scaling
- **AI enthusiasts** - Create specialized agents for your domain
- **Documentation writers** - Help others get started

## Community

- [Discord](https://discord.com/invite/bXgbDNpj) - Chat with other builders
- [GitHub Issues](https://github.com/agentsystems/agentsystems/issues) - Bug reports and features

## License

Licensed under the [Apache-2.0 license](./LICENSE).
