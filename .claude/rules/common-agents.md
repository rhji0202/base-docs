# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent                | Purpose                   | When to Use                           |
| -------------------- | ------------------------- | ------------------------------------- |
| planner              | Implementation planning   | Complex features, refactoring         |
| architect            | System design             | Architectural decisions               |
| tdd-guide            | Test-driven development   | New features, bug fixes               |
| code-reviewer        | Code review               | After writing code                    |
| security-reviewer    | Security analysis         | Before commits                        |
| build-error-resolver | Fix build errors          | When build fails                      |
| e2e-runner           | E2E testing               | Critical user flows                   |
| refactor-cleaner     | Dead code cleanup         | Code maintenance                      |
| doc-updater          | Documentation             | Updating docs                         |

## Available Skills

User-invocable via `/<name>`. Located in `~/.claude/skills/`.

### Bootstrap & Maintenance

| Skill          | Purpose                                       | When to Use                          |
| -------------- | --------------------------------------------- | ------------------------------------ |
| setup          | Bootstrap tom plugin into a project           | First install, base-docs template    |
| init-project   | Fill all `{UNSET}` markers interactively      | After /setup, before first feature   |
| update         | Refresh rules/scripts/settings (keeps docs/)  | After plugin upgrade                 |
| sync-registry  | Sync `registry.md` with actual files          | After Feature or domain change       |

### Document Creation

| Skill        | Purpose                                  | When to Use            |
| ------------ | ---------------------------------------- | ---------------------- |
| new-feature  | Create PRD with auto-assigned F-XXX ID   | New feature draft      |
| new-adr      | Create ADR with auto-assigned ADR-XXX ID | Architecture decision  |
| new-rfc      | Create RFC with auto-assigned RFC-XXX ID | Change proposal        |
| new-bug      | Create bug report with auto BUG-XXX ID   | Bug tracking           |
| new-domain   | Scaffold DDD domain folder + CLAUDE.md   | New business domain    |

### Planning & Discovery

| Skill           | Purpose                                                   | When to Use                       |
| --------------- | --------------------------------------------------------- | --------------------------------- |
| deep-interview  | Socratic clarification of vague requests                  | Goals/scope/constraints unclear   |
| analyze-docs    | Cross-check a request against existing docs               | Before /plan-feature              |
| plan-feature    | 6-phase end-to-end plan (PRD → domain → API → schema)     | Feature design                    |
| plan-impl       | Code implementation plan derived from spec docs           | After /plan-feature, before code  |

### Recommended Flow

```
/setup → /init-project → /deep-interview → /analyze-docs
       → /plan-feature → /new-feature (PRD) → /new-domain → /new-adr
       → /plan-impl → implementation → /sync-registry
```

## Immediate Agent Usage

No user prompt needed:

1. Complex feature requests - Use **planner** agent
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **tdd-guide** agent
4. Architectural decision - Use **architect** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution

Launch 3 agents in parallel:

1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary

First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:

- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
