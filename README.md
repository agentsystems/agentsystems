# AgentSystems

**The open infrastructure for commoditizing intelligence**

## The Problem That Changes Everything

Every breakthrough in computing followed the same pattern: proprietary technology becomes open infrastructure, costs collapse, innovation explodes. We're doing this for AI agents.

**Today:** To use any AI agent, you must send your data to their servers. Unacceptable for healthcare, finance, government, or anyone who values privacy.

**Tomorrow:** Run any AI agent on YOUR infrastructure. Your data never leaves. You see everything. Trust through transparency, not promises.

![AgentSystems Demo](docs/demo.gif)
*Deploy a specialized AI agent in 30 seconds, complete data sovereignty*

## This is for you if...

- ✅ You handle sensitive data (healthcare, finance, legal, government)
- ✅ You want to use AI but can't send data to OpenAI/Anthropic/Google  
- ✅ You need audit trails for compliance
- ✅ You believe AI should be accessible to everyone, not just big tech customers
- ✅ You want to build and monetize specialized AI agents

## Try it in 60 Seconds

```bash
# One-line install (macOS/Linux)
curl -fsSL https://raw.githubusercontent.com/agentsystems/agentsystems/main/install.sh | sh

# Initialize and start
agentsystems init my-deployment
cd my-deployment && agentsystems up

# Use it
curl -X POST http://localhost:18080/invoke/hello-world-agent \
  -H "Content-Type: application/json" \
  -d '{"task": "Write a haiku about data sovereignty"}'
```

**That's it.** Your AI runs locally. Your data stays local.

## The Core Insight

Thousands of specialized AI agents are being built. But to use them, you must send your data to unknown servers. **This trust barrier blocks an entire AI economy from emerging.**

AgentSystems breaks that barrier. Run any agent on YOUR infrastructure. See everything it does. When trust is no longer the bottleneck, intelligence becomes a commodity.

## How It Works

```bash
# Invoke an agent through the gateway
curl -X POST http://localhost:18080/invoke/medical-diagnosis-agent \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "headache, fever", "history": "patient-data.json"}'

# Your data stays in your infrastructure
# Agent runs in isolation  
# Every operation is logged
```

**What changes when agents become trustless:**
- Cost → just your compute
- Risk → dramatically reduced via sandboxing
- Switching → instant, no lock-in
- Trust → verified through transparency

## Who's Using AgentSystems

- 🏥 **Healthcare**: Processing patient data in HIPAA-compliant environments
- 🏦 **Banking**: Running risk analysis without exposing customer data  
- 🏛️ **Government**: Deploying AI within air-gapped networks
- 🚀 **Startups**: Building AI products without infrastructure overhead

[Share your use case →](https://github.com/agentsystems/agentsystems/discussions)

## What Exists Today

**Working now:**
- ✅ Container-based isolation
- ✅ Network egress filtering
- ✅ Multi-registry support
- ✅ Audit logging
- ✅ Resource management

**Coming soon:**
- 🚧 Agent marketplace
- 🚧 WebAssembly isolation
- 🚧 Kubernetes operator

## Build Your Own Agent

```python
# Your agent runs on user infrastructure
# You never see their data
# Share capabilities, not risk

from agentsystems import Agent

@agent.invoke
async def analyze(data):
    # Your specialized logic here
    return {"result": "..."}
```

[Full agent tutorial →](docs/build-agent.md)

## The Technical Foundation

**Architecture**: Gateway orchestrates isolated containers with controlled egress  
**Security**: Defense in depth with audit logging  
**Philosophy**: Simple, composable, open  

Details in [docs/architecture.md](docs/architecture.md)

## FAQ

**Q: Is this production-ready?**  
Core isolation works. Evaluate based on your risk tolerance. Early adopters are helping us harden it.

**Q: Why not just use Docker?**  
Docker isolates applications. We add controls specific to running untrusted AI with sensitive data.

**Q: What's the business model?**  
There isn't one. This is infrastructure. Think Linux, not Red Hat. The core remains 100% open source forever.

**Q: How does this project sustain itself?**  
Like successful open infrastructure before us: corporate sponsors, cloud providers offering managed versions, and companies building commercial services on top. [Become a sponsor →](https://github.com/sponsors/agentsystems)

**Q: What if malicious agents steal data?**  
Multiple defenses: isolation, egress filtering, audit logging. Defense in depth approach significantly reduces risk.

## Security Notice

AgentSystems provides isolation and audit capabilities designed to reduce risk when running untrusted code. Users are responsible for:
- Reviewing agent code and permissions
- Configuring appropriate egress policies  
- Ensuring compliance with their specific regulatory requirements

See [SECURITY.md](SECURITY.md) for details.

## Contributing

We need:
- **Security researchers** to break and fix isolation
- **Platform engineers** to scale the system
- **Domain experts** to build specialized agents  
- **Organizations** to deploy and provide feedback

[Contribution Guide →](CONTRIBUTING.md)

## Join the Revolution

This is bigger than any company or product. We're building open infrastructure for the future of AI deployment.

```bash
git clone https://github.com/agentsystems/agentsystems
```

---

<p align="center">
<strong>When every agent can run anywhere, intelligence becomes abundant.</strong>
</p>

<p align="center">
<a href="https://github.com/agentsystems/agentsystems">GitHub</a> •
<a href="https://discord.gg/agentsystems">Discord</a> •
<a href="https://docs.agentsystems.ai">Documentation</a>
</p>

<p align="center">
<a href="https://github.com/agentsystems/agentsystems/stargazers">⭐ Star us</a> - Help make intelligence a commodity, not a luxury
</p>

<p align="center">
<sub>The commons for AI agents</sub>
</p>