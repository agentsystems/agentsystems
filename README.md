# AgentSystems

> [!NOTE]
> **Pre-Release Software** - AgentSystems is in active development. Join our [Discord](https://discord.com/invite/JsxDxQ5zfV) for updates and early access.

## Self-Hosted Platform for AI Agents

> 💡 **Self-hosted platform for discovering and running AI agents.**
> Deploy specialized agents on your infrastructure—without building from scratch or using SaaS.

AgentSystems is a standardized runtime for third-party AI agents. Deploy on your laptop, home server, or air-gapped network. Built with container isolation, federated discovery, and provider abstraction.

**Key Features:**
- 🌐 **Federated Agent Ecosystem** - Git-based index, no gatekeepers
- 🛡️ **Container Isolation** - Separate containers with egress filtering
- 🔌 **Provider Portability** - Works with OpenAI, Anthropic, Ollama
- 🏠 **Your Infrastructure** - Deploy on your own servers

Compatible with major AI providers and local models. Single-command install for macOS/Linux.

## Overview

**AgentSystems in 100 Seconds:**

[![AgentSystems in 100 Seconds](https://img.youtube.com/vi/YRDamSh7M-I/maxresdefault.jpg)](https://www.youtube.com/watch?v=YRDamSh7M-I)

📺 **[Full Demo & Walkthrough (9 min)](https://www.youtube.com/watch?v=G2csNRrVXM8)** - Complete installation and UI guide

## Quick Start

**One-command install** (macOS/Linux):

```bash
curl -fsSL https://github.com/agentsystems/agentsystems/releases/latest/download/install.sh | sh
```

This installs:
- `agentsystems` CLI
- Docker (if not present)
- Required dependencies

**Next steps:**
```bash
agentsystems init agentsystems-platform && cd agentsystems-platform
agentsystems up
open http://localhost:3001  # Web UI
```

📖 [Full installation guide](https://docs.agentsystems.ai/getting-started)

## Why AgentSystems

**The problem:** Teams want to use specialized AI agents (codebase migration, research synthesis, visual content analysis, structured data extraction) but face a dilemma:

- 🔒 **SaaS agents** require sending data to third parties
- 🛠️ **Building from scratch** takes weeks of development per agent (most teams lack ML expertise)
- 🐳 **Manual Docker orchestration** means configuring networks, volumes, proxies, and API keys for each agent (time-consuming, error-prone)

**AgentSystems provides** a standardized runtime and ecosystem:

- **For teams without infrastructure expertise:** Single command deployment (networking, isolation, audit logging)
- **For compliance-focused organizations:** Run agents on-premises or air-gapped with configurable egress controls
- **For developers building products:** Browse community agents instead of building from scratch
- **For enterprises:** Discover, evaluate, and deploy agents with container isolation and audit logging

### Federated Agent Ecosystem

AgentSystems uses a Git-based agent index where:
- Developers publish agents via GitHub forks
- Anyone can run their own agent index alongside the AgentSystems community index
- No central authority controls listing or distribution
- Uses GitHub's fork and authentication mechanisms for attribution

**Why this matters:** Agent developers can publish once and reach users who self-host, while organizations can create private indexes with company-approved agents.

### Container Isolation & Network Controls

Each agent runs in its own Docker container with:
- Configurable network egress filtering (HTTP proxy with allowlists)
- Thread-scoped artifact storage (per-request file directories)
- Hash-chained audit logs for tamper detection
- Lazy startup and automatic resource management

### Provider Portability

Agents built with the AgentSystems toolkit use a `get_model()` abstraction that routes to configured providers:
- Switch from OpenAI to Anthropic to Ollama through configuration
- Run the same agent with different models and providers
- Reduce vendor lock-in at the agent level

## Available Agents

Browse community agents at [agentsystems.github.io/agent-index](https://agentsystems.github.io/agent-index/)

The agent index is a federated, Git-based registry where developers can publish agents and users can discover them. Agents are organized by developer namespace and include metadata about capabilities, model requirements, and usage examples.

*Don't see what you need?* [Build your own agent](https://docs.agentsystems.ai/deploy-agents/quickstart) and publish it to the index.

## How It Works

```mermaid
graph TB
    subgraph "Your Infrastructure"
        App[Your Application]
        GW[Gateway :18080]
        Agent[Third-Party Agent<br/>Container]
        Proxy[Egress Proxy]
        Storage[Thread Storage]
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
5. **Thread-Scoped Storage** - Separate artifact directories per request
6. **Hash-Chained Audit Logs** - Tamper detection for operation tracking

## Who Should Use This?

**✅ Good fit:**
- Teams without dedicated infrastructure engineers
- Startups prototyping AI products quickly
- Organizations requiring on-premises or air-gapped deployment
- Agent developers seeking distribution channels
- Teams needing audit trails

**❌ Might not need this:**
- Teams with existing container orchestration and dedicated DevOps resources
- Single-agent deployments where manual Docker setup is sufficient
- Organizations comfortable with SaaS agent providers

---

## Comparison to Other Tools

**vs. LangChain/CrewAI:** AgentSystems is a runtime for agents built with these frameworks. Your agent code uses LangChain; AgentSystems deploys and runs it.

**vs. Portkey/LiteLLM:** Different layers. AI gateways route API calls; AgentSystems runs complete applications with workflows and file I/O.

**vs. Manual Docker:** You can build this yourself. AgentSystems is the pre-built, standardized version.

---

## Platform Components

The platform consists of 6 interdependent repositories:

| Component | What It Does | Technology | Latest Version |
|-----------|--------------|------------|----------------|
| **[agent-control-plane](https://github.com/agentsystems/agent-control-plane)** | Gateway, orchestration, egress proxy | FastAPI, PostgreSQL | ![Version](https://img.shields.io/github/v/release/agentsystems/agent-control-plane?label=&color=blue) |
| **[agentsystems-sdk](https://github.com/agentsystems/agentsystems-sdk)** | CLI tool for deployment | Python, Docker | ![Version](https://img.shields.io/github/v/release/agentsystems/agentsystems-sdk?label=&color=blue) |
| **[agentsystems-ui](https://github.com/agentsystems/agentsystems-ui)** | Web interface for management | React, TypeScript | ![Version](https://img.shields.io/github/v/release/agentsystems/agentsystems-ui?label=&color=blue) |
| **[agentsystems-toolkit](https://github.com/agentsystems/agentsystems-toolkit)** | Library for building agents | Python, LangChain | ![Version](https://img.shields.io/github/v/release/agentsystems/agentsystems-toolkit?label=&color=blue) |
| **[agent-template](https://github.com/agentsystems/agent-template)** | Starter template for new agents | FastAPI, LangGraph | rolling |
| **[agent-index](https://github.com/agentsystems/agent-index)** | Federated agent discovery | GitHub Pages | rolling |

**For most users:** You only interact with `agentsystems-sdk` (CLI) and `agentsystems-ui` (web interface).

**For agent developers:** Use `agent-template` and `agentsystems-toolkit` to build, then publish to `agent-index`.

## Platform Capabilities

### Security & Isolation Features
- Docker container isolation with separate namespaces per agent
- Network egress filtering via HTTP CONNECT proxy
- Configurable URL allowlists per agent
- Hash-chained audit logging for tamper detection
- Thread-scoped artifact storage (per-request file directories)

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

**Personal Projects:**
- Run a document analysis agent to process research papers
- Deploy a code review agent for open-source projects
- Use a data extraction agent to structure web content

**Startups & Small Teams:**
- Build an AI feature without hiring ML engineers
- Test multiple specialized agents before committing to one approach
- Run agents on-premises instead of using cloud services

**Enterprise & Compliance:**
- Deploy agents in air-gapped networks
- Audit all agent operations with hash-chained logs
- Run third-party agents with configurable network controls

## Documentation

- **[Getting Started](https://docs.agentsystems.ai/getting-started)** - Deploy your first agent
- **[Architecture Overview](https://docs.agentsystems.ai/getting-started/key-concepts)** - Deep dive into system design
- **[Agent Development](https://docs.agentsystems.ai/deploy-agents/quickstart)** - Build custom agents
- **[Configuration](https://docs.agentsystems.ai/configuration)** - Advanced configurations

## For Agent Developers

- **[Build an Agent](https://docs.agentsystems.ai/deploy-agents/quickstart)** - Development guide
- **[Publish to Index](https://docs.agentsystems.ai/deploy-agents/list-on-index)** - List your agent for discovery
- **[Agent Index](https://github.com/agentsystems/agent-index)** - Federated discovery repository

## Contributing

We welcome contributions across the stack:
- 🤖 **Build Agents** - Create specialized agents and publish to the index
- 🔒 **Security** - Improve isolation, audit mechanisms, or egress controls
- 📚 **Documentation** - Write guides, tutorials, or API references
- 🐛 **Bug Reports** - Help identify and fix issues

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## Community

- [Discord](https://discord.com/invite/JsxDxQ5zfV) - Chat with developers and contributors
- [GitHub Issues](https://github.com/agentsystems/agentsystems/issues) - Bug reports and feature requests

## License

Licensed under the [Apache-2.0 license](./LICENSE).
