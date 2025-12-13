# J.A.R.V.I.S. - Personal AI Security Assistant

A privacy-focused personal AI assistant with episodic memory, multi-provider LLM support, and hardened emergency response capabilities.

---

## Overview

This system solves a fundamental problem with AI assistants: **lack of continuity and context**. By implementing episodic and semantic memory layers, JARVIS maintains consistent understanding across sessions while providing robust security features for high-risk situations.

---

## Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                     JARVIS ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Claude    │    │   Ollama    │    │   Memory    │     │
│  │    API      │◄──►│   (Local)   │◄──►│   Layer     │     │
│  │  (Cloud)    │    │   Gemma 2B  │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            ▼                                │
│                   ┌─────────────────┐                       │
│                   │   LLM Manager   │                       │
│                   │  (Provider      │                       │
│                   │   Switching)    │                       │
│                   └────────┬────────┘                       │
│                            │                                │
│         ┌──────────────────┼──────────────────┐             │
│         ▼                  ▼                  ▼             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Security   │    │   Voice     │    │  Emergency  │     │
│  │  Sandbox    │    │  Interface  │    │    Mode     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Design Decisions

**1. Dual LLM Provider Strategy**

*Challenge:* Cloud AI services require internet and send data externally. Local models are private but less capable.

*Approach:* Implemented provider abstraction allowing runtime switching between Claude API (capability) and Ollama (privacy). System auto-detects availability and can fall back gracefully.

*Why:* Users need control over when their data leaves the device. Privacy mode enables sensitive operations without cloud dependency.

**2. Episodic + Semantic Memory**

*Challenge:* AI assistants give inconsistent analysis across sessions with no context retention.

*Approach:* Two-layer memory system:
- **Episodic:** Stores specific interactions with full context (who, what, when, outcome)
- **Semantic:** Extracts patterns and preferences from episodes over time

*Why:* Enables consistent personality, remembers past decisions, learns user patterns.

**3. Command Security Sandboxing**

*Challenge:* AI with system access is dangerous. Commands could be injected or coerced.

*Approach:* Multi-layer security:
- Static analysis scans commands for dangerous patterns
- Approval workflow (auto-approve safe, prompt for risky, block critical)
- Sandboxed execution environment
- Complete audit logging

*Why:* Defense-in-depth prevents both accidental and malicious command execution.

**4. Emergency Mode Architecture**

*Challenge:* High-risk situations (traffic stops, etc.) require tamper-resistant documentation that survives coercion.

*Approach:* Hardened recording system with:
- LLM lockout (AI cannot be voice-commanded during emergency)
- Anti-coercion authentication mechanisms
- Redundant storage with geographic distribution
- Dead man's switch escalation
- Graceful degradation under resource constraints

*Why:* When the stakes are highest, the system must be resistant to defeat by external actors.

---

## Technical Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| LLM (Cloud) | Claude API | High-capability responses |
| LLM (Local) | Ollama + Gemma 2B | Private/offline operation |
| Backend | Python + FastAPI | API server |
| Database | SQLite | Memory persistence |
| Embeddings | sentence-transformers | Semantic search |
| Encryption | AES-256 | Data protection |

---

## Key Features

### LLM Provider Management
- Runtime switching between cloud and local models
- Automatic fallback on provider failure
- Request tracking and performance monitoring
- Privacy mode toggle

### Memory System
- Conversation history with context preservation
- Pattern extraction from interactions
- Semantic search across memories
- Context synthesis for responses

### Security Layer
- Command threat detection
- Tiered approval workflow
- Sandboxed execution
- Comprehensive audit trail

### Emergency Response
- Multiple activation methods
- Tamper-resistant recording
- Anti-coercion mechanisms
- Automated escalation protocols

---

## Security Philosophy

This project demonstrates security thinking at multiple levels:

**Threat Modeling:** Systems designed assuming adversarial conditions, not just accidental misuse.

**Defense in Depth:** No single point of failure. Multiple layers must be defeated simultaneously.

**Graceful Degradation:** Reduced functionality is better than complete failure. Systems maintain core functions under resource constraints.

**Privacy by Default:** Data stays local unless explicitly sent externally. User controls what leaves the device.

**Coercion Resistance:** Authentication and deactivation mechanisms designed to resist forced compliance.

---

## Project Status

| Component | Status |
|-----------|--------|
| LLM Provider Manager | ✅ Complete |
| Memory Layer (Episodic) | 🔄 In Progress |
| Memory Layer (Semantic) | 🔄 In Progress |
| Security Sandbox | 📋 Specified |
| Emergency Mode | 📋 Specified |
| Voice Interface | 📋 Specified |
| Android Companion | 📋 Specified |

---

## Documentation

- [Quick Start Guide](JARVIS_QUICK_START.md) - Getting started
- [Emergency Mode Specification](EMERGENCY_MODE_COMPLETE_SPEC.md) - Security architecture
- [Android Implementation Plan](ANDROID_IMPLEMENTATION_PLAN.md) - Mobile companion
- [Testing Protocol](EMULATOR_TESTING_PROTOCOL.md) - QA procedures

---

## What This Demonstrates

**For technical reviewers**, this project shows:

1. **Security Architecture** - Threat modeling, defense in depth, coercion resistance
2. **System Design** - Multi-provider abstraction, memory layers, graceful degradation
3. **API Integration** - Claude API, Ollama, async Python patterns
4. **Privacy Engineering** - Local-first design, encryption, data minimization

---

## Development Approach

This system was architected using AI-assisted development workflows. I designed the security architecture, made all technical decisions regarding threat models and defense mechanisms, and can explain every component and why it exists.

---

## License

MIT License - See LICENSE file for details.

---

*"The right to be secure in their persons, houses, papers, and effects."*
