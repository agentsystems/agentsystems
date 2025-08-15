# AgentSystems

**The open infrastructure for commoditizing intelligence**

![AgentSystems Demo](docs/demo.gif)
*Deploy a specialized AI agent in 30 seconds, your data never leaves your infrastructure*

## This is for you if...

- ✅ You handle sensitive data (healthcare, finance, legal, government)
- ✅ You want to use AI but can't send data to OpenAI/Anthropic/Google  
- ✅ You need audit trails for compliance
- ✅ You believe AI should be accessible to everyone, not just big tech customers
- ✅ You want to build and monetize specialized AI agents

## This is NOT for you if...

- ❌ You're fine sending all data to external APIs

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

## Learning from Open Source History

**Linux (1991)**: Made operating systems free → Runs 96% of servers  
**Apache (1995)**: Made web servers free → Enabled the internet explosion  
**Docker (2013)**: Made deployment portable → Transformed software delivery  
**Kubernetes (2014)**: Made orchestration standard → Became the cloud OS  

**AgentSystems (2024)**: Makes AI agents trustless → ?

We're following the same open source infrastructure playbook.

## The Insight That Changes Everything

Agents are becoming trivially easy to build. Any competent developer can create a specialized AI agent in days. Soon there will be thousands. Then tens of thousands.

But agents are impossible to trust. To use one, you must send your data to unknown servers, run by unknown people, with unknown security.

**This single trust barrier is blocking an entire economy from emerging.**

AgentSystems breaks that barrier. When trust is no longer the bottleneck, intelligence becomes a commodity.

## What Commoditized Intelligence Looks Like

Imagine opening your terminal and finding:

```
Specialized agents for:
- Financial analysis
- Medical diagnosis  
- Legal review
- Code generation
- Scientific research
- Any domain you need

Your deployment time: seconds
Your data shared: stays local
Your risk: controlled
```

The technical foundation for this exists **today**. The ecosystem is beginning to emerge.

## How We Get There

AgentSystems provides sandboxed execution for AI agents with auditable data isolation:

```bash
# Example: Invoke an agent through the gateway
curl -X POST http://localhost:18080/invoke/hello-world-agent \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"task": "analyze", "data": "local-file.csv"}'

# Your data stays in your infrastructure
# Agent runs in isolation
# Every operation is logged
# Trust verified through transparency
```

When the cost and risk of trying new agents becomes negligible, something fundamental shifts:
- **Cost of trying an agent → just compute** (your infrastructure)
- **Risk of data exposure → dramatically reduced** (sandboxed execution)
- **Switching cost → instant** (no lock-in)
- **Trust requirement → verified through audit** (transparent operations)

This is how AI capabilities become accessible to everyone.

## The World This Enables

### Startups Access Sophisticated AI
Smaller organizations can run the same specialized agents as large enterprises, using their own infrastructure.

### Experts Can Share Their Knowledge  
Specialists can package their expertise as agents that others can run locally, without infrastructure overhead.

### Every Organization Maintains Sovereignty
Hospitals run diagnostic AI while maintaining compliance. Banks analyze data without external exposure. Governments deploy AI within their security requirements.

### Innovation Becomes Permissionless
Anyone, anywhere can build and share agents. No gatekeepers. No API limits. No platform lock-in.

## Who's Using AgentSystems

- 🏥 **Healthcare**: Processing patient data while maintaining HIPAA compliance
- 🏦 **Banking**: Running risk analysis without exposing customer data  
- 🏛️ **Government**: Deploying AI within air-gapped networks
- 🚀 **Startups**: Building AI products without infrastructure overhead

[Share your use case →](https://github.com/agentsystems/agentsystems/discussions)

## This Only Works as Open Source

Like Linux, Apache, or Bitcoin - this infrastructure must be:

**Transparent**: You can't trust a black box to isolate untrusted code  
**Neutral**: No entity should control AI deployment  
**Persistent**: Infrastructure outlives companies  
**Forkable**: If we fail, others can succeed  

The moment there's a commercial gatekeeper, the vision collapses.

## What Exists Today

The core platform is real and functional. Current capabilities:
- ✅ Container-based isolation
- ✅ Network egress filtering
- ✅ Multi-registry support
- ✅ Audit logging
- ✅ Resource management

What we're building:
- 🚧 Agent discovery interface
- 🚧 Reputation systems
- 🚧 Performance optimizations

The revolution:
- 🚀 Thousands of specialized agents
- 🚀 Instant deployment anywhere
- 🚀 True data sovereignty
- 🚀 Commoditized intelligence

## Join the Revolution

### If You're a Developer
Build agents that run anywhere:
```python
# Your agent runs on user infrastructure
# You never see their data
# Share capabilities, not risk
```

### If You're an Organization  
Deploy AI without compromise:
- Run competitor analysis tools without exposing your data
- Use medical AI while maintaining patient privacy
- Deploy financial models while protecting trade secrets

### If You're a Contributor
Help build the commons:
```bash
git clone https://github.com/agentsystems/agentsystems
```

Priority areas:
- Security hardening
- Kubernetes operator
- Agent templates
- Ecosystem tools

## The Technical Foundation

**Architecture**: Gateway orchestrates isolated containers with controlled egress  
**Security**: Defense in depth with audit logging  
**Philosophy**: Simple, composable, open  

Details in [docs/architecture.md](docs/architecture.md)

## Why This Matters

We're at an inflection point. AI is powerful enough to transform knowledge work, but the current model - sending data to big tech - is unsustainable and inequitable.

The next era of AI will be:
- **Abundant** - Thousands of specialized agents
- **Accessible** - Available to everyone
- **Auditable** - You see what happens to your data
- **Autonomous** - No external dependencies

Either we build open infrastructure for this future, or we accept permanent dependence on a few large companies.

The AgentSystems community is building this future, together.

## Principles

1. **Data sovereignty is non-negotiable**
2. **Openness enables trust**  
3. **Simplicity over features**
4. **Community over company**
5. **Progress over perfection**

## FAQ

**Q: Is this production-ready?**  
Core isolation works. Evaluate based on your risk tolerance. Early adopters are helping us harden it.

**Q: Why not just use Docker?**  
Docker isolates applications. We add controls specific to running untrusted AI with sensitive data.

**Q: What's the business model?**  
There isn't one. This is infrastructure. Companies will build services on top. Think Linux, not Red Hat. The core remains 100% open source forever.

**Q: How does this project sustain itself?**
Like successful open infrastructure before us: corporate sponsors, cloud providers offering managed versions, and companies building commercial services on top. [Become a sponsor →](https://github.com/sponsors/agentsystems)

**Q: What if malicious agents steal data?**  
Multiple defenses: isolation, egress filtering, audit logging. Defense in depth approach significantly reduces risk.

**Q: Why now?**  
LLMs made agent creation easy. Docker made isolation practical. The pieces just came together.

## Security Notice

AgentSystems provides isolation and audit capabilities designed to reduce risk when running untrusted code. Users are responsible for:
- Reviewing agent code and permissions
- Configuring appropriate egress policies  
- Ensuring compliance with their specific regulatory requirements
- Evaluating security risks for their use case

See [SECURITY.md](SECURITY.md) for details.

## The Call to Action

The infrastructure for trustless AI won't build itself. We need:

- **Security researchers** to break and fix isolation
- **Platform engineers** to scale the system
- **Domain experts** to build specialized agents  
- **Organizations** to deploy and provide feedback
- **Everyone** to imagine what's possible

This is bigger than any company or product. We're building open infrastructure for the future of AI deployment.

---

<p align="center">
<strong>When every agent can run anywhere, intelligence becomes abundant.</strong>
</p>

<p align="center">
<strong>When intelligence becomes abundant, everything changes.</strong>
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