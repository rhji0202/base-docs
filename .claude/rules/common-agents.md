# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent                | Purpose                   | When to Use                           |
| -------------------- | ------------------------- | ------------------------------------- |
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
| update         | Refresh rules/scripts/settings (keeps docs/)  | After plugin upgrade                 |

### Planning & Discovery

| Skill           | Purpose                                                   | When to Use                       |
| --------------- | --------------------------------------------------------- | --------------------------------- |
| deep-interview  | Socratic clarification of vague requests                  | Goals/scope/constraints unclear   |

> **문서 작성은 스킬이 아니라 템플릿 복사로 합니다.** 기획·프론트·백엔드 문서는
> 각 폴더의 `_template.md`를 복사해 만듭니다. (옛 PRD/ADR/RFC/도메인/registry 생성
> 스킬과 에이전트는 이 3단계 구조에서 제거되었습니다.)

### Recommended Flow

```
/setup → /deep-interview
       → docs/1-feat/ (기획) → docs/2-web/ (프론트 설계) → docs/3-api/ (백엔드 설계)
       → implementation
```

## Immediate Agent Usage

No user prompt needed:

1. New feature — 먼저 `docs/1-feat/` 기획 문서부터 작성 (코드보다 문서 먼저)
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **tdd-guide** agent

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
