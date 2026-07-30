---
name: parallel-agents
description: Multi-agent orchestration patterns. Use when multiple independent tasks can run with different domain expertise or when comprehensive analysis requires multiple perspectives.
allowed-tools: Read, Glob, Grep
---

# Native Parallel Agents

> Orchestration through Antigravity's built-in Agent Tool

## Overview

This skill enables coordinating multiple specialized agents through Antigravity's native agent system. Unlike external scripts, this approach keeps all orchestration within Antigravity's control.

## When to Use Orchestration

✅ **Good for:**
- Complex tasks requiring multiple expertise domains
- Code analysis from security, performance, and quality perspectives
- Comprehensive reviews (architecture + security + testing)
- Feature implementation needing Flutter UI + BLoC logic + Unit tests

❌ **Not for:**
- Simple, single-domain tasks
- Quick fixes or small changes
- Tasks where one agent suffices

---

## Native Agent Invocation

### Single Agent
```
Use the security-auditor agent to review authentication
```

### Sequential Chain
```
1. Use explorer-agent to map the widget tree.
2. Use mobile-developer to implement the new screen.
3. Use test-engineer to verify with Widget tests.
```

### With Context Passing
```
Use mobile-developer to create the LoginBloc.
Pass that bloc's state definition to test-engineer to generate bloc_test cases.
```

### Resume Previous Work
```
Resume agent [agentId] and continue with additional requirements.
```

---

## Orchestration Patterns

### Pattern 1: Comprehensive Analysis
```
Agents: explorer-agent → [domain-agents] → synthesis

1. explorer-agent: Map codebase and architecture
2. security-auditor: Mobile security scan (MASVS)
3. mobile-developer: Business logic and UI review
4. performance-optimizer: Jank and memory audit
5. test-engineer: Test coverage analysis
6. Synthesize all findings
```

### Pattern 2: Feature Review
```
Agents: affected-domain-agents → test-engineer

1. Identify affected features (Presentation? Domain? Data?)
2. Invoke mobile-developer for the implementation
3. test-engineer verifies with unit and widget tests
4. Synthesize recommendations
```

### Pattern 3: Security Audit
```
Agents: security-auditor → penetration-tester → synthesis

1. security-auditor: Configuration and code review
2. penetration-tester: Active vulnerability testing
3. Synthesize with prioritized remediation
```

---

## Available Agents

| Agent | Expertise | Trigger Phrases |
|-------|-----------|-----------------|
| `orchestrator` | Coordination | "comprehensive", "multi-perspective" |
| `mobile-developer` | Flutter Development | "ui", "bloc", "implementation" |
| `test-engineer` | Testing & TDD | "unit test", "widget test", "mocktail" |
| `security-auditor` | Mobile Defense | "security", "auth", "storage" |
| `performance-optimizer` | Perf & App Size | "slow", "jank", "fps", "profile" |
| `qa-automation` | E2E & Patrol | "integration", "device", "pipeline" |
| `explorer-agent` | Discovery | "explore", "map", "structure" |
| `project-planner` | Planning | "implementation plan", "breakdown" |
| `product-manager` | Requirements | "user story", "specs", "app store" |
| `debugger` | Troubleshooting | "bug", "crash", "error" |
| `code-archaeologist` | Refactoring | "legacy", "technical debt" |
| `penetration-tester` | Offensive Sec | "pentest", "exploit", "red team" |
| `documentation-writer` | Docs | "readme", "changelog" |

---

## Antigravity Built-in Agents

These work alongside custom agents:

| Agent | Model | Purpose |
|-------|-------|---------|
| **Explore** | Haiku | Fast read-only codebase search |
| **Plan** | Sonnet | Research during plan mode |
| **General-purpose** | Sonnet | Complex multi-step modifications |

Use **Explore** for quick searches, **custom agents** for domain expertise.

---

## Synthesis Protocol

After all agents complete, synthesize:

```markdown
## Orchestration Synthesis

### Task Summary
[What was accomplished]

### Agent Contributions
| Agent | Finding |
|-------|---------|
| security-auditor | Found insecure storage |
| mobile-developer | Identified logic duplication |

### Consolidated Recommendations
1. **Critical**: [Issue from Agent A]
2. **Important**: [Issue from Agent B]
3. **Nice-to-have**: [Enhancement from Agent C]

### Action Items
- [ ] Fix critical security issue
- [ ] Refactor API endpoint
- [ ] Add missing tests
```

---

## Best Practices

1. **Available agents** - 13 specialized agents can be orchestrated
2. **Logical order** - Discovery → Analysis → Implementation → Testing
3. **Share context** - Pass relevant findings to subsequent agents
4. **Single synthesis** - One unified report, not separate outputs
5. **Verify changes** - Always include test-engineer for code modifications

---

## Key Benefits

- ✅ **Single session** - All agents share context
- ✅ **AI-controlled** - Claude orchestrates autonomously
- ✅ **Native integration** - Works with built-in Explore, Plan agents
- ✅ **Resume support** - Can continue previous agent work
- ✅ **Context passing** - Findings flow between agents
