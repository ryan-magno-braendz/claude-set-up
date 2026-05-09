# Agent Orchestration

> Core principles: see [CLAUDE.md](../../CLAUDE.md) Rule 2.
> Full team build template: see `build-with-agent-team` skill.

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |
| rust-reviewer | Rust code review | Rust projects |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests — Use **planner** agent
2. Code just written/modified — Use **code-reviewer** agent
3. Bug fix or new feature — Use **tdd-guide** agent
4. Architectural decision — Use **architect** agent

## Execution Strategy

### Wave Dependency Chain

Each wave depends on the output of the previous one:

```
Research Wave → results feed into →
  Planning Wave → plan feeds into →
    Implementation Wave → code feeds into →
      Test Wave → results feed into →
        Review Wave
```

Never skip a wave or start the next before the previous completes its output.

### Parallelization Decision Rule

Before spawning agents in parallel, check all four:
1. Does Agent B need Agent A's output? → **Sequential**
2. Do both agents read/write the same files? → **Sequential**
3. Are both agents answering independent questions? → **Parallel**
4. Are both agents reviewing separate modules? → **Parallel**

### Research Dependencies

Research agents often depend on each other. Identify dependencies before spawning:

```
# WRONG: Parallel when results depend on each other
├── Agent 1: Search Context7 for library X docs
├── Agent 2: Build implementation using library X patterns  ← needs Agent 1's output
└── Agent 3: Write tests for library X integration         ← needs Agent 2's output

# RIGHT: Sequential chain — each agent consumes the previous output
Agent 1: Search Context7 for library X docs
  → pass results to →
Agent 2: Plan implementation using those docs
  → pass plan to →
Agent 3: Implement based on plan
```

When researching a solution, the lead must **wait for research results** before spawning planning or implementation agents. Research sources (Context7, Tavily, web search, MS Learn) may return information that changes the approach entirely.

### When to Parallelize

Parallel execution is valid **only** when agents operate on independent inputs with no shared state:

```
# GOOD: Independent research across different sources
├── Agent 1: Search Context7 for React docs
├── Agent 2: Search Tavily for deployment patterns
└── Agent 3: Search MS Learn for Azure config
→ Lead waits for all, synthesizes, then proceeds

# GOOD: Independent reviews of completed code
├── Agent 1: Security review of auth module
├── Agent 2: Performance review of cache module
└── Agent 3: Code review of API module

# GOOD: Independent test suites after implementation is done
├── Agent 1: Unit tests
├── Agent 2: Integration tests
└── Agent 3: E2E tests

# BAD: Parallel when one agent needs another's output
├── Agent 1: Research library docs
├── Agent 2: Implement using that library  ← can't start yet
```

## Contract Definition

Before spawning parallel implementation agents, the lead defines integration contracts. For the full spawn template, see the `build-with-agent-team` skill.

### Step 1: Map the Contract Chain

Identify which layers must agree on interfaces:
- Database → Backend: function signatures, data shapes, model definitions
- Backend → Frontend: API URLs, request/response JSON, status codes, SSE formats
- Service A → Service B: message formats, event types, error envelopes

### Step 2: Author Exact Contracts

Each contract must specify:
- Exact endpoint URLs (including trailing slash conventions)
- Request/response JSON shapes (explicit structures, not prose)
- Status codes for success and error cases
- SSE event types with exact JSON format (if applicable)
- Error response format

### Step 3: Identify Cross-Cutting Concerns

Behaviors that span agents and get missed unless assigned:
- Streaming data storage semantics (per-chunk vs accumulated)
- URL conventions (trailing slashes, path params, query params)
- Response envelopes (flat vs nested)
- Error shapes (status codes, error body format)
- UI accessibility (aria-labels for automated testing)

Assign EACH concern to exactly one agent. Include in their spawn prompt.

### Contract Quality Check

Before including a contract in agent prompts:
- [ ] URLs exact, including trailing slashes
- [ ] Response shapes are explicit JSON, not prose
- [ ] Error responses specified
- [ ] Storage semantics clear
- [ ] Each cross-cutting concern assigned to one agent

## Spawn Prompt Essentials

Each agent's prompt must include (full template in `build-with-agent-team` skill):

1. **Ownership** — files/directories they own, what's off-limits
2. **Contract they produce** — the interface they implement
3. **Contract they consume** — the interface they depend on
4. **Cross-cutting concerns they own** — explicitly listed
5. **Coordination rules** — when to message lead, when to flag deviations
6. **Validation checklist** — specific commands to run before reporting done

## Lead Validation Protocol

After ALL agents report done:

### Contract Diff
- Ask each agent: "What exact endpoints/functions did you implement?"
- Compare Backend's curl commands vs Frontend's fetch URLs
- Flag mismatches before integration testing

### End-to-End Checks
1. Can the system start?
2. Does the happy path work?
3. Do integrations connect?
4. Are edge cases handled?

### On Failure
- Identify which agent's domain contains the bug
- Re-spawn that agent with the specific issue
- Re-run validation after fix

## Phase Reference

| Phase | Parallel-Safe | Sequential Required |
|-------|--------------|-------------------|
| Research | Multiple sources (Context7, Tavily, MS Learn) | Research → Planning (results change approach) |
| Planning | Multiple review perspectives on same plan | Plan → Implementation |
| Implementation | Agents with contracts + disjoint file ownership | Any agent needing another's output |
| Testing | Unit, integration, E2E on completed code | Test → Review |
| Code Review | Multiple reviewers on separate modules | Review → Fix → Re-review |
| Debugging | Multiple approaches on same bug | Diagnosis → Fix |

## Multi-Perspective Analysis

For complex problems, use split role sub-agents **in parallel** (these are independent by nature):
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker

## Cross-Session Orchestration (Agent Orchestrator)

Everything above describes **within-session** orchestration: subagents inside one Claude Code session working on one task. For **cross-session** orchestration — multiple independent Claude Code sessions working on separate issues — use Agent Orchestrator (AO).

### When to Use AO vs Within-Session Agents

| Scenario | Use |
|----------|-----|
| One feature with frontend + backend + tests | Within-session (Rule 2 waves) |
| Three separate bug fixes from the issue tracker | AO (`ao batch-spawn #1 #2 #3`) |
| Sprint backlog with 5 independent issues | AO (`ao batch-spawn`) |
| Complex feature needing research → plan → implement | Within-session (wave chain) |
| PR has review comments to address | AO (`ao review-check`) |
| Multiple PRs need review comment responses | AO (`ao review-check`) |

### AO Command Reference

| Command | Purpose |
|---------|---------|
| `ao start [project]` | Start orchestrator and dashboard |
| `ao spawn <issue>` | Launch session for one issue in isolated worktree |
| `ao batch-spawn <issues...>` | Launch sessions for multiple issues |
| `ao status` | Monitor all sessions (branch, PR, CI status) |
| `ao send <session> <message>` | Send message to a running session |
| `ao review-check [project]` | Auto-address PR review comments |
| `ao session ls` | List all sessions |
| `ao open <session>` | Open session in terminal tab |
| `ao stop` | Stop orchestrator and dashboard |

### Relationship to Within-Session Agents

Each AO-spawned session is a full Claude Code instance that follows all existing rules:
- Rule 1 suggests the best approach within the session
- Rule 2 governs subagent orchestration within the session
- Rule 3 maintains documentation

AO configuration lives in `agent-orchestrator.yaml` at the project root. The `agentRules` field should **reference** existing rules rather than duplicating them.

### Session Lifecycle

```
ao spawn #123
  → creates worktree (isolated branch)
  → launches Claude Code session
  → session follows Rules 1-3 internally
  → creates PR when done
  → AO reactions handle CI failures and review feedback
  → merged → worktree cleaned up
```
