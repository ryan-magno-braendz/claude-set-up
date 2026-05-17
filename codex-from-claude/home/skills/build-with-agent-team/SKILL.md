---
name: build-with-agent-team
description: Build a project using Claude Code Agent Teams with tmux split panes. Takes a plan document path and optional team size. Use when you want multiple agents collaborating on a build.
argument-hint: '[plan-path] [num-agents]'
disable-model-invocation: true
---

# Build with Agent Team

You are coordinating a build using Claude Code Agent Teams. Read the plan document, determine the right team structure, spawn teammates, and orchestrate the build.

## Arguments

- **Plan path**: `$ARGUMENTS[0]` - Path to a markdown file describing what to build
- **Team size**: `$ARGUMENTS[1]` - Number of agents (optional)

## Step 1: Read the Plan

Read the plan document at `$ARGUMENTS[0]`. Understand:
- What are we building?
- What are the major components/layers?
- What technologies are involved?
- What are the dependencies between components?

## Step 2: Determine Team Structure

If team size is specified (`$ARGUMENTS[1]`), use that number of agents.

If NOT specified, analyze the plan and determine the optimal team size based on:
- **Number of independent components** (frontend, backend, database, infra, etc.)
- **Technology boundaries** (different languages/frameworks = different agents)
- **Parallelization potential** (what can be built simultaneously?)

**Guidelines:**
- 2 agents: Simple projects with clear frontend/backend split
- 3 agents: Full-stack apps (frontend, backend, database/infra)
- 4 agents: Complex systems with additional concerns (testing, DevOps, docs)
- 5+ agents: Large systems with many independent modules

For each agent, define:
1. **Name**: Short, descriptive (e.g., "frontend", "backend", "database")
2. **Ownership**: What files/directories they own exclusively
3. **Does NOT touch**: What's off-limits (prevents conflicts)
4. **Key responsibilities**: What they're building

## Step 3: Set Up Agent Team

Enable tmux split panes so each agent is visible:
```
teammateMode: "tmux"
```

## Step 4: Define Contracts

Before spawning agents, the lead reads the plan and defines the integration contracts between layers. This focused upfront work is what enables all agents to spawn in parallel without diverging on interfaces.

### Map the Contract Chain

Identify which layers need to agree on interfaces:
```
Database → function signatures, data shapes → Backend
Backend → API contract (URLs, response shapes, SSE format) → Frontend
```

### Author the Contracts

From the plan, define each integration contract with enough specificity that agents can build to it independently:

**Database → Backend contract:**
- Function signatures (create, read, update, delete)
- Pydantic model definitions
- Data shapes and types

**Backend → Frontend contract:**
- Exact endpoint URLs (including trailing slash conventions)
- Request/response JSON shapes (exact structures, not prose descriptions)
- Status codes for success and error cases
- SSE event types with exact JSON format
- Response envelopes (flat vs nested)

### Identify Cross-Cutting Concerns

Some behaviors span multiple agents and will fall through the cracks unless explicitly assigned:

- **Streaming data storage**: If backend streams chunks to frontend, should chunks be stored individually in the DB or accumulated into one row?
- **URL conventions**: Trailing slashes, path parameters, query params
- **Response envelopes**: Flat objects vs nested wrappers
- **Error shapes**: How errors are returned (status codes, error body format)
- **UI accessibility**: Interactive elements need aria-labels for automated testing

### Contract Quality Checklist

Before including a contract in agent prompts, verify:
- Are URLs exact, including trailing slashes?
- Are response shapes explicit JSON, not prose descriptions?
- Are all SSE event types documented with exact JSON?
- Are error responses specified?
- Are storage semantics clear?

## Step 5: Spawn All Agents in Parallel

With contracts defined, spawn all agents simultaneously. Enter **Delegate Mode** (Shift+Tab) before spawning. You should not implement code yourself — your role is coordination.

### Spawn Prompt Structure
```
You are the [ROLE] agent for this build.

## Your Ownership
- You own: [directories/files]
- Do NOT touch: [other agents' files]

## What You're Building
[Relevant section from plan]

## Contracts

### Contract You Produce
[Include the lead-authored contract this agent is responsible for]

### Contract You Consume
[Include the lead-authored contract this agent depends on]

### Cross-Cutting Concerns You Own
[Explicitly list integration behaviors this agent is responsible for]

## Coordination
- Message the lead if you discover something that affects a contract
- Ask before deviating from any agreed contract
- Flag cross-cutting concerns that weren't anticipated
- Share with [other agent] when: [trigger]
- Challenge [other agent]'s work on: [integration point]

## Before Reporting Done
Run these validations and fix any failures:
1. [specific validation command]
2. [specific validation command]
Do NOT report done until all validations pass.
```

## Step 6: Facilitate Collaboration

### During Implementation

- Relay messages between agents when they flag contract issues
- If an agent needs to deviate from a contract, evaluate the change, update the contract, and notify all affected agents
- Unblock agents waiting on decisions
- Track progress through the shared task list

### Pre-Completion Contract Verification

Before any agent reports "done", run a contract diff:
- "Backend: what exact curl commands test each endpoint?"
- "Frontend: what exact fetch URLs are you calling with what request bodies?"
- Compare and flag mismatches before integration testing

### Cross-Review
Each agent reviews another's work:
- Frontend reviews Backend API usability
- Backend reviews Database query patterns
- Database reviews Frontend data access patterns

## Task Management

Create a shared task list:
```
[ ] Agent A: Build UI components
[ ] Agent B: Implement API endpoints
[ ] Agent C: Build schema and data layer
[ ] Agent A + B + C: Integration testing (blocked by all implementation tasks)
```

## Common Pitfalls to Prevent

1. **File conflicts**: Two agents editing the same file → Assign clear ownership
2. **Lead over-implementing**: You start coding → Stay in Delegate Mode
3. **Isolated work**: Agents don't talk → Require explicit handoffs via lead relay
4. **Vague boundaries**: "Help with backend" → Specify exact files/responsibilities
5. **Missing dependencies**: Agent B waits on Agent A forever → Track blockers actively
6. **Parallel spawn without contracts**: Integration failures
7. **Implicit contracts**: Require exact JSON shapes
8. **Orphaned cross-cutting concerns**: Explicitly assign to one agent
9. **Per-chunk storage**: Accumulate chunks into single rows
10. **Hidden UI elements**: Add aria-labels

## Definition of Done

The build is complete when:
1. All agents report their work is done
2. Each agent has validated their own domain
3. Integration points have been tested
4. Cross-review feedback has been addressed
5. The plan's acceptance criteria are met
6. **Lead agent has run end-to-end validation**

## Step 7: Validation

### Agent Validation

**Database agent** validates:
- Schema creates without errors
- CRUD operations work
- Foreign keys and cascades behave correctly
- Indexes exist for common queries

**Backend agent** validates:
- Server starts without errors
- All API endpoints respond correctly
- Request/response formats match the spec
- Error cases return proper status codes
- SSE streaming works (if applicable)

**Frontend agent** validates:
- TypeScript compiles
- Build succeeds
- Dev server starts
- Components render without console errors

### Lead Validation (End-to-End)

After ALL agents return control to you:

1. **Can the system start?**
2. **Does the happy path work?**
3. **Do integrations connect?**
4. **Are edge cases handled?**

If validation fails:
- Identify which agent's domain contains the bug
- Re-spawn that agent with the specific issue
- Re-run validation after fix

## Execute

Now read the plan at `$ARGUMENTS[0]` and begin:

1. Read and understand the plan
2. Determine team size (use `$ARGUMENTS[1]` if provided, otherwise decide)
3. Define agent roles, ownership, cross-cutting concern assignments, and validation requirements
4. Map the contract chain and define all integration contracts
5. Enter Delegate Mode (Shift+Tab)
6. Spawn all agents in parallel with contracts and validation checklists
7. Monitor agents, relay messages, mediate contract deviations
8. Run contract diff before integration
9. When all agents return, run end-to-end validation yourself
10. If validation fails, re-spawn the relevant agent with the specific issue
11. Confirm the build meets the plan's requirements
