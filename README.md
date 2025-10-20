# AgentSystems

> [!NOTE]
> **Pre-Release Software** - AgentSystems is in active development. Join our [Discord](https://discord.com/invite/JsxDxQ5zfV) for updates and early access.

## The Open Runtime for AI Agents

**Run third-party AI agents on infrastructure you control.**

AgentSystems is a self-hosted platform for deploying AI agents from an emerging decentralized ecosystem. Deploy agents on your laptop, home server, cloud infrastructure, or air-gapped networks. Built around container isolation, federated discovery, and provider abstraction.

- 🌐 **Federated Agent Ecosystem** - Git-based agent index using GitHub forks, no central gatekeepers
- 🛡️ **Designed with a Zero-Trust Approach** - Container isolation + egress control for running third-party agents
- 🔌 **Provider Portability** - Agents integrate with OpenAI, Anthropic, Bedrock, Ollama—write once, run anywhere
- 🏠 **Your Infrastructure** - Control over where your data goes and how agents execute

Compatible with major AI providers and local models. Single-command install for macOS/Linux.

## Overview

**AgentSystems in 100 Seconds:**

[![AgentSystems in 100 Seconds](https://img.youtube.com/vi/YRDamSh7M-I/maxresdefault.jpg)](https://www.youtube.com/watch?v=YRDamSh7M-I)

📺 **[Full Demo & Walkthrough (9 min)](https://www.youtube.com/watch?v=G2csNRrVXM8)** - Complete installation and UI guide

## Quick Start

```bash
curl -fsSL https://github.com/agentsystems/agentsystems/releases/latest/download/install.sh | sh
```

## Why AgentSystems

The platform addresses a fundamental challenge: how do you benefit from specialized AI agents without sending your data to third-party services or building everything from scratch?

**Traditional approaches:**
- Send your data to AI services (lose control)
- Build custom agents from scratch (time-consuming, complex)

**The AgentSystems approach:**
- Run third-party agents in your environment
- Access a federated ecosystem of specialized agents
- Maintain control over data and infrastructure

### Federated Agent Ecosystem

AgentSystems uses a Git-based agent index where:
- Developers publish agents via GitHub forks
- Anyone can operate their own agent index alongside community indexes
- No central authority controls listing or distribution
- Uses GitHub's fork and authentication mechanisms for attribution

This creates a decentralized ecosystem where agent developers can share or commercialize their work while operators maintain infrastructure control.

### Designed with a Zero-Trust Approach

Each agent runs in its own Docker container with:
- Configurable network egress filtering (HTTP proxy with allowlists)
- Thread-scoped artifact storage (isolated per-request file access)
- Hash-chained audit logs for tamper-evident operation tracking
- Lazy startup and automatic resource management

### Provider Portability

Agents built with the AgentSystems toolkit use a `get_model()` abstraction that routes to configured providers:
- Switch from OpenAI to Anthropic to Ollama through configuration
- Run the same agent with different models and providers
- Reduce vendor lock-in at the agent level

This is the "write once, run anywhere" moment for AI agents.

## How It Works

```mermaid
graph TB
    subgraph "Your Infrastructure"
        App[Your Application]
        GW[Gateway :18080]
        Agent[Third-Party Agent<br/>Container]
        Proxy[Egress Proxy]
        Storage[Isolated Storage]
        Audit[Hash-Chained Logs]
    end

    subgraph "External"
        Index[Agent Index<br/>GitHub-Based]
        Allow[approved.com ✓]
        Block[evil.com ✗]
        AI[AI Providers<br/>OpenAI/Anthropic/Ollama]
    end

    Index -.->|Pull Agent| GW
    App -->|1. Request| GW
    GW -->|2. Route + Inject Credentials| Agent
    Agent -->|3. Network Call| Proxy
    Proxy -->|Allowed| Allow
    Proxy -.->|Blocked| Block
    Agent -->|API Calls| AI
    Agent <-->|Read/Write| Storage
    Agent -->|4. Results| GW
    GW -->|5. Response| App
    GW -->|Log Operations| Audit

    style Agent fill:#1a4d5c
    style Proxy fill:#2d5f3f
    style Block fill:#5c1a1a
    style Audit fill:#3d3d5c
```

**Architecture Highlights:**

1. **Federated Discovery** - Pull agents from decentralized Git-based indexes
2. **Runtime Injection** - Your credentials and model connections injected at runtime into agent containers
3. **Container Isolation** - Each agent runs in its own Docker container with separate namespaces
4. **Default-Deny Egress** - Configurable network filtering with allowlist-based controls
5. **Thread-Scoped Storage** - Isolated artifact storage per request
6. **Tamper-Evident Logging** - Hash-chained audit logs for operation tracking

## Platform Components

| Repository | Purpose | Technology | Last Release |
|------------|---------|------------|--------------|
| [agent-control-plane](https://github.com/agentsystems/agent-control-plane) | Gateway & orchestration | FastAPI, PostgreSQL, Docker | ![Release](https://img.shields.io/github/release-date/agentsystems/agent-control-plane?label=) |
| [agentsystems-sdk](https://github.com/agentsystems/agentsystems-sdk) | CLI deployment tool | Python, Docker Compose | ![Release](https://img.shields.io/github/release-date/agentsystems/agentsystems-sdk?label=) |
| [agentsystems-ui](https://github.com/agentsystems/agentsystems-ui) | Web interface | React, TypeScript | ![Release](https://img.shields.io/github/release-date/agentsystems/agentsystems-ui?label=) |
| [agentsystems-toolkit](https://github.com/agentsystems/agentsystems-toolkit) | Agent development library | Python, LangChain | ![Release](https://img.shields.io/github/release-date/agentsystems/agentsystems-toolkit?label=) |
| [agent-template](https://github.com/agentsystems/agent-template) | Reference implementation | FastAPI, LangGraph | rolling |
| [agent-index](https://github.com/agentsystems/agent-index) | Federated discovery system | GitHub Pages, YAML | rolling |

## Platform Capabilities

### Security & Isolation
- Docker container isolation with separate namespaces per agent
- Network egress filtering via HTTP CONNECT proxy
- Configurable URL allowlists per agent
- Hash-chained audit logging for tamper-evident operation tracking
- Thread-scoped artifact storage (isolated per-request file access)

### Agent Management
- Automatic agent discovery via Docker labels
- Lazy container startup on first request
- Configurable idle timeouts and resource limits
- Multi-registry authentication (Docker Hub, Harbor, ECR, self-hosted)
- Agent lifecycle management and version switching

### Developer Experience
- Simple FastAPI contract for building agents
- Model provider abstraction (`get_model()` for LangChain, etc.)
- Built-in file upload/download handling
- Progress tracking for long-running operations
- Complete reference implementation with LangGraph

## Example Use Cases

**For Developers:**
- **Personal AI Infrastructure** - Run your own agents without cloud dependencies
- **Local Development** - Test and debug agent workflows on your laptop
- **Content Creation** - Process documents and media with specialized agents
- **Prototyping** - Build AI products with self-hosted infrastructure

**For Organizations:**
- **Startups** - Deploy AI capabilities without managing complex infrastructure
- **Research Labs** - Experiment with multi-agent systems and novel architectures
- **Tech Companies** - Build internal tooling with specialized AI agents
- **Data Teams** - Process proprietary data with agents that run in your environment

## Documentation

- **[Getting Started](https://docs.agentsystems.ai/quickstart)** - Deploy your first agent
- **[Architecture Overview](https://docs.agentsystems.ai/architecture)** - Deep dive into system design
- **[Security Model](https://docs.agentsystems.ai/security)** - Isolation, egress control, and audit trails
- **[Agent Development](https://docs.agentsystems.ai/agents)** - Build custom agents
- **[API Reference](https://docs.agentsystems.ai/api)** - Complete endpoint documentation
- **[Enterprise Deployment](https://docs.agentsystems.ai/enterprise)** - Advanced configurations

## For Agent Developers

- **[Build an Agent](https://docs.agentsystems.ai/agents)** - Development guide and best practices
- **[Publish to Index](https://docs.agentsystems.ai/deploy-agents/list-on-index)** - List your agent for discovery
- **[Agent Index](https://github.com/agentsystems/agent-index)** - Federated discovery repository

## Contributing

We're building in the open and welcome contributions:
- **Agent Developers** - Build specialized agents for the ecosystem
- **Security Researchers** - Help strengthen isolation and audit mechanisms
- **Platform Engineers** - Improve deployment, scaling, and orchestration
- **AI Researchers** - Explore multi-agent architectures and novel approaches
- **Documentation** - Help developers get started

## Community

- [Discord](https://discord.com/invite/JsxDxQ5zfV) - Chat with developers and contributors
- [GitHub Issues](https://github.com/agentsystems/agentsystems/issues) - Bug reports and feature requests

## License

Licensed under the [Apache-2.0 license](./LICENSE).
