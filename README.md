# AgentSystems

**Open infrastructure for running AI agents on your own hardware**

Deploy any AI agent on your infrastructure. Process data locally. Configure your own security controls.

## Why AgentSystems?

Organizations with sensitive data need AI but can't use cloud services:
- **Healthcare** systems can't send patient data to OpenAI
- **Banks** can't expose customer records to external APIs  
- **Government** agencies require air-gapped deployments

AgentSystems is designed to enable organizations to run AI agents locally with:
- ✅ **Local processing** - Data can be processed within your infrastructure
- ✅ **Audit capabilities** - Operations can be logged for compliance
- ✅ **Agent portability** - Switch between agents when needed
- ✅ **Self-hosted model** - Use your own compute resources

## Technical Innovation

- **Universal Agent Compatibility** - Run any containerized agent from any registry (Docker Hub, Harbor, ECR)
- **Cryptographic Audit Trail** - Hash-chained PostgreSQL logs provide tamper-evident compliance records
- **Zero-Trust Isolation** - Complete sandboxing between agents with controlled network egress
- **Multi-Registry Federation** - Connect to multiple registries simultaneously for agent marketplace
- **Thread-Scoped Execution** - Every request gets isolated storage context at `/artifacts/{thread-id}/`
- **Hot-Swap Capability** - Switch agent implementations without stopping workloads
- **Lazy Resource Management** - Agents start on-demand and stop when idle

## Platform Components

| Repository | Purpose | Technology |
|------------|---------|------------|
| [agent-control-plane](https://github.com/agentsystems/agent-control-plane) | Gateway & orchestration | FastAPI, PostgreSQL, Docker |
| [agentsystems-sdk](https://github.com/agentsystems/agentsystems-sdk) | CLI deployment tool | Python, Docker Compose |
| [agentsystems-ui](https://github.com/agentsystems/agentsystems-ui) | Web interface | React, TypeScript |
| [agentsystems-toolkit](https://github.com/agentsystems/agentsystems-toolkit) | Agent development | Python, LangChain |
| [agent-template](https://github.com/agentsystems/agent-template) | Reference agent | FastAPI, LangGraph |

## How It Works

```
Your App → Gateway (18080) → Agent Container → Results
                ↓                      ↓
          Audit Logs            Local Processing
```

The gateway discovers agents via Docker labels, routes requests, applies configured policies, and logs operations. Each agent runs in a Docker container with configurable network access.

## Quick Start

```bash
# Install (60 seconds)
curl -fsSL https://github.com/agentsystems/agentsystems/releases/latest/download/install.sh | sh

# Deploy platform
agentsystems init my-deployment
cd my-deployment && agentsystems up

# Run an agent
curl -X POST http://localhost:18080/invoke/hello-world-agent \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Analyze this data locally"}'
```

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

```python
from fastapi import FastAPI, Request

app = FastAPI()

@app.post("/invoke")
async def invoke(request: Request, data: dict):
    # Process data within this container
    return {"result": "processed"}

@app.get("/health")
async def health():
    return {"status": "ok"}
```

[Full agent development guide →](https://docs.agentsystems.ai/agents)

## Summary

AgentSystems provides infrastructure for deploying AI agents on your own hardware. It's designed for organizations that need to run AI agents locally due to regulatory, security, or privacy requirements.

The platform provides tools for agent orchestration and management, allowing you to focus on building specialized agents for your use cases.

## Documentation

- **[Getting Started Guide](https://docs.agentsystems.ai/quickstart)** - First deployment in 5 minutes
- **[Architecture Overview](https://docs.agentsystems.ai/architecture)** - Deep dive into system design
- **[Security Model](https://docs.agentsystems.ai/security)** - Isolation and audit details
- **[Agent Development](https://docs.agentsystems.ai/agents)** - Build custom agents
- **[API Reference](https://docs.agentsystems.ai/api)** - Complete endpoint documentation
- **[Enterprise Deployment](https://docs.agentsystems.ai/enterprise)** - Production configurations

## Example Use Cases

- **Healthcare**: Medical record processing in controlled environments
- **Financial Services**: Risk analysis on local infrastructure
- **Government**: Document processing in isolated networks
- **Legal**: Document analysis within secure boundaries

## Contributing

We welcome contributions in:
- Security hardening and testing
- Agent templates for specific industries
- Performance optimizations
- Documentation improvements

## Support

- [GitHub Issues](https://github.com/agentsystems/agentsystems/issues) - Bug reports and features
- [Discord Community](https://discord.gg/agentsystems) - Real-time help

## License

All use of this software is governed by the [LICENSE](LICENSE).