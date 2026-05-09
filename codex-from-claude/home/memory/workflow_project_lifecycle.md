---
name: Full Project Lifecycle Workflow
description: Exhaustive step-by-step workplan for building projects from scratch — multi-agent orchestration as default, every installed skill/command/MCP server listed, overlapping tools for cross-checking
type: reference
---

# Full Project Lifecycle Workflow (Exhaustive + Multi-Agent)

Every command you can use at each stage. Overlapping tools are listed intentionally — use them to cross-check, get second opinions, or reassess decisions.

**Default mode: Multi-agent.** At every phase, the lead agent (you're talking to) should spawn specialized agents in parallel where applicable. Agents communicate through the lead, which coordinates handoffs.

---

## Agent Orchestration Patterns

Use these to spawn and coordinate agents throughout all phases:

| Command | What it does |
|---------|--------------|
| `/build-with-agent-team plan.md [N]` | Spawn N agents in tmux split panes with contracts and ownership |
| `/superpowers:dispatching-parallel-agents` | Parallelize 2+ independent tasks with no shared state |
| `/superpowers:subagent-driven-development` | Execute independent tasks with subagents in current session |
| `/claude-session-driver:driving-claude-code-sessions` | PM mode: launch workers, assign work, monitor, review, collect |
| `/devfleet` | ECC: orchestrate parallel agents via DevFleet — plan, dispatch, monitor, reports |
| `/orchestrate` | ECC: sequential and tmux/worktree orchestration guidance |
| `/multi-workflow` | ECC: multi-model collaborative development |

### Agent Roles Reference

These are the roles that should be spawned as needed. The lead assigns roles based on the phase:

| Role | Responsibility | When to spawn |
|------|---------------|---------------|
| **Researcher** | Search docs (Context7, Tavily, MS Learn), find patterns, gather context | Planning, implementation, debugging |
| **Planner** | Break work into tasks, define contracts, sequence dependencies | Planning phases |
| **Architect** | Design system structure, data flow, API contracts | Phase 2-3 |
| **Implementer** | Write code, one per module/layer | Implementation |
| **Tester** | Write and run tests, QA browser testing | Testing phases |
| **Reviewer** | Code review, security audit, quality gate | Pre-ship |
| **Documenter** | Update docs, changelog, README | Post-ship |

---

## Phase 0: Ideation & Brainstorming

**Goal:** Shape the idea, validate demand, explore the design space.

### Agent Strategy
```
Lead Agent (you)
├── Researcher Agent 1 → Tavily: search competitors, market landscape
├── Researcher Agent 2 → Tavily: extract content from competitor sites
├── Researcher Agent 3 → Context7/MS Learn: research relevant tech docs
└── Lead synthesizes findings → feeds into /office-hours or /superpowers:brainstorming
```

### Primary
| Step | Command | What it does |
|------|---------|--------------|
| 0.1 | `/office-hours` | YC-style brainstorming — 6 forcing questions (demand, status quo, specificity, wedge, observation, future-fit). Two modes: startup or builder. Saves a design doc |
| 0.2 | `/superpowers:brainstorming` | Explore user intent, requirements, and design before implementation |

### Research (spawn in parallel)
| Step | Command | What it does |
|------|---------|--------------|
| 0.3 | Tavily `tavily_search` | Search the web for competitors, solutions, market landscape |
| 0.4 | Tavily `tavily_extract` | Extract content from specific URLs (competitor pages, articles) |
| 0.5 | Tavily `tavily_crawl` | Crawl an entire site for deeper research |
| 0.6 | Tavily `tavily_research` | Deep research on a topic |
| 0.7 | `/docs` | Look up current library/topic documentation via Context7 |
| 0.8 | `/microsoft-docs:microsoft-docs` | Research MS/Azure technologies via official docs |

### Presentation
| Step | Command | What it does |
|------|---------|--------------|
| 0.9 | Gamma `generate` | Create a pitch deck, project overview, or design doc |
| 0.10 | `/frontend-slides` | Create HTML presentations from scratch or convert PPT |

**Output:** Design doc, PRD, or pitch deck — enriched by parallel research.

---

## Phase 1: Project Initialization

**Goal:** Set up project structure, planning system, and design system.

### Agent Strategy
```
Lead Agent
├── Researcher Agent 1 → Context7: research frameworks/libraries for the stack
├── Researcher Agent 2 → Tavily: search for best practices, starter templates
├── Researcher Agent 3 → MS Learn: research Azure/MS services if applicable
└── Lead runs /gsd:new-project with research results as context
    └── Design Agent → /design-consultation to create DESIGN.md
```

### Setup
| Step | Command | What it does |
|------|---------|--------------|
| 1.1 | `git init` | Initialize repo |
| 1.2 | `/gsd:new-project` | GSD: deep context gathering, PROJECT.md, roadmap with phases |
| 1.3 | `/gsd:settings` | Configure GSD workflow toggles and model profile |
| 1.4 | `/gsd:set-profile` | Switch model profile (quality/balanced/budget/inherit) |

### Design System
| Step | Command | What it does |
|------|---------|--------------|
| 1.5 | `/design-consultation` | Create DESIGN.md — aesthetic, typography, color, layout, spacing, motion |
| 1.6 | `/gsd:ui-phase` | Generate UI-SPEC.md design contract for frontend phases |

### External Tracking (optional)
| Step | Command | What it does |
|------|---------|--------------|
| 1.7 | ClickUp `clickup_create_list` | Create ClickUp project/list |
| 1.8 | ClickUp `clickup_create_task` | Create tasks in ClickUp |
| 1.9 | Task Master `initialize_project` | Initialize Task Master in the project |
| 1.10 | Task Master `parse_prd` | Generate task breakdown from PRD |

### Codebase Analysis (existing projects)
| Step | Command | What it does |
|------|---------|--------------|
| 1.11 | `/gsd:map-codebase` | Analyze codebase with parallel mapper agents — tech, arch, quality, concerns |
| 1.12 | `/update-codemaps` | Update codemaps for the project |
| 1.13 | `/context-budget` | Analyze context window usage across agents, skills, MCP servers, rules |

**Output:** PROJECT.md, ROADMAP.md, DESIGN.md, UI-SPEC.md, `.planning/` directory.

---

## Phase 2: Plan Review & Refinement

**Goal:** Stress-test the plan from every angle. Use ALL reviewers — each gives a different perspective.

### Agent Strategy
```
Lead Agent
├── Researcher Agent → Context7 + Tavily + MS Learn: research tech feasibility in parallel
├── CEO Reviewer Agent → /plan-ceo-review: challenge scope & ambition
├── Eng Reviewer Agent → /plan-eng-review: lock architecture & edge cases
├── Design Reviewer Agent → /plan-design-review: rate design dimensions
└── Lead synthesizes all reviews → resolves conflicts → updates plan
```

### Strategy Review (spawn as parallel review agents)
| Step | Command | What it does |
|------|---------|--------------|
| 2.1 | `/plan-ceo-review` | CEO/founder mode — challenge scope, think bigger, find the 10-star product. 4 modes: scope expansion, selective expansion, hold scope, scope reduction |
| 2.2 | `/plan-eng-review` | Eng manager mode — lock architecture, data flow, edge cases, test coverage, performance |
| 2.3 | `/plan-design-review` | Designer mode — rate each design dimension 0-10, explain what makes it a 10, fix the plan |

### Context Gathering
| Step | Command | What it does |
|------|---------|--------------|
| 2.4 | `/gsd:discuss-phase` | Gather phase context through adaptive questioning (use `--auto` to skip interactive) |
| 2.5 | `/gsd:list-phase-assumptions` | Surface Claude's assumptions about approach before planning |
| 2.6 | `/gsd:research-phase` | Research how to implement a phase (standalone) |

### Cross-Check with ECC
| Step | Command | What it does |
|------|---------|--------------|
| 2.7 | `/plan` | ECC: restate requirements, assess risks, create step-by-step plan. WAIT for user confirm |
| 2.8 | `/prompt-optimize` | ECC: analyze a draft prompt, output optimized version (advisory only) |

**Output:** Battle-tested plan reviewed from strategy, architecture, and design perspectives — with conflicts resolved.

---

## Phase 3: Detailed Planning

**Goal:** Break the plan into executable tasks with dependencies and acceptance criteria.

### Agent Strategy
```
Lead Agent (Planner)
├── Researcher Agent 1 → Context7: research library APIs, patterns for each component
├── Researcher Agent 2 → Tavily: search for implementation approaches, tutorials
├── Researcher Agent 3 → MS Learn: research MS/Azure services needed
├── Planner waits for research → creates PLAN.md with /gsd:plan-phase
├── Task Breakdown Agent → Task Master parse_prd + expand_all
└── Lead reviews plan completeness → /superpowers:writing-plans as cross-check
```

### Planning
| Step | Command | What it does |
|------|---------|--------------|
| 3.1 | `/gsd:plan-phase` | Create detailed PLAN.md with verification loop |
| 3.2 | `/superpowers:writing-plans` | Create step-by-step implementation plan from spec/requirements |
| 3.3 | `/gsd:add-phase` | Add phase to end of current milestone |
| 3.4 | `/gsd:insert-phase` | Insert urgent work as decimal phase (e.g., 72.1) between existing phases |
| 3.5 | `/gsd:remove-phase` | Remove a future phase and renumber |
| 3.6 | `/gsd:plan-milestone-gaps` | Create phases to close gaps identified by milestone audit |

### Research During Planning (spawn in parallel)
| Step | Command | What it does |
|------|---------|--------------|
| 3.7 | Context7 `resolve-library-id` + `query-docs` | Look up library docs for tech choices |
| 3.8 | `/microsoft-docs:microsoft-docs` | Research MS/Azure tech |
| 3.9 | `/microsoft-docs:microsoft-code-reference` | Find working code samples, verify API signatures |
| 3.10 | `/microsoft-docs:microsoft-skill-creator` | Generate a skill for any MS technology |
| 3.11 | Tavily `tavily_search` | Search for implementation approaches, tutorials |

### Task Tracking
| Step | Command | What it does |
|------|---------|--------------|
| 3.12 | Task Master `parse_prd` | Auto-generate task breakdown from PRD |
| 3.13 | Task Master `analyze_project_complexity` | Analyze complexity of tasks |
| 3.14 | Task Master `expand_task` / `expand_all` | Break tasks into subtasks |
| 3.15 | `/gsd:add-todo` | Capture task from conversation context |
| 3.16 | `/gsd:add-backlog` | Park an idea in backlog (999.x numbering) |
| 3.17 | `/gsd:plant-seed` | Capture forward-looking idea with trigger conditions |
| 3.18 | ClickUp `clickup_create_task` | Create tasks in ClickUp |

**Output:** PLAN.md, task breakdown, dependency graph, acceptance criteria — informed by parallel research.

---

## Phase 4: Implementation

**Goal:** Build it. Multi-agent is the default.

### Agent Strategy (Full Team)
```
Lead Agent (Coordinator — does NOT write code, stays in Delegate Mode)
│
├── RESEARCH WAVE (parallel, before coding starts)
│   ├── Researcher Agent 1 → Context7: fetch docs for all libraries in the plan
│   ├── Researcher Agent 2 → Tavily: search for code examples, patterns
│   └── Researcher Agent 3 → MS Learn: fetch relevant MS/Azure docs
│
├── IMPLEMENTATION WAVE (parallel, after research completes)
│   ├── Frontend Agent → owns src/components/, src/pages/, src/styles/
│   ├── Backend Agent → owns src/api/, src/services/, src/middleware/
│   ├── Database Agent → owns src/db/, migrations/, seeds/
│   └── Infra Agent → owns Dockerfile, CI/CD, config files
│
├── TEST WAVE (parallel, after implementation)
│   ├── Unit Test Agent → write unit tests per module
│   ├── Integration Test Agent → write integration tests
│   └── E2E Test Agent → write Playwright E2E tests
│
└── Lead runs integration validation when all agents report done
```

### Execution Strategies

#### Strategy A: Agent Teams (recommended for complex projects)
| Step | Command | What it does |
|------|---------|--------------|
| 4A.1 | `/build-with-agent-team plan.md [N]` | Spawn N agents in tmux split panes with contracts and ownership |
| 4A.2 | `/superpowers:dispatching-parallel-agents` | Parallelize 2+ independent tasks |
| 4A.3 | `/superpowers:subagent-driven-development` | Execute independent tasks with subagents in current session |
| 4A.4 | `/claude-session-driver:driving-claude-code-sessions` | PM mode: launch workers, assign work, monitor, review, collect |
| 4A.5 | `/devfleet` | ECC: orchestrate parallel agents via DevFleet — plan, dispatch, monitor, read reports |
| 4A.6 | `/orchestrate` | ECC: sequential and tmux/worktree orchestration guidance |

#### Strategy B: Solo Execution (simple projects)
| Step | Command | What it does |
|------|---------|--------------|
| 4B.1 | `/gsd:execute-phase` | Execute all plans with wave-based parallelization |
| 4B.2 | `/superpowers:executing-plans` | Execute plan in separate session with review checkpoints |
| 4B.3 | `/superpowers:using-git-worktrees` | Isolate feature work in git worktrees |
| 4B.4 | `/gsd:fast` | Execute a trivial task inline — no subagents, no planning overhead |
| 4B.5 | `/gsd:quick` | Quick task with GSD guarantees (atomic commits) but skip optional agents |

#### Strategy C: Autonomous
| Step | Command | What it does |
|------|---------|--------------|
| 4C.1 | `/gsd:autonomous` | Run all remaining phases automatically (discuss→plan→execute) |

#### Strategy D: Multi-Model Collaboration (ECC)
| Step | Command | What it does |
|------|---------|--------------|
| 4D.1 | `/multi-plan` | Multi-model collaborative planning |
| 4D.2 | `/multi-execute` | Multi-model collaborative execution |
| 4D.3 | `/multi-workflow` | Multi-model collaborative development workflow |
| 4D.4 | `/multi-frontend` | Frontend-focused multi-model development |
| 4D.5 | `/multi-backend` | Backend-focused multi-model development |

### Test-Driven Development (spawn TDD agent per module)
| Step | Command | What it does |
|------|---------|--------------|
| 4E.1 | `/superpowers:test-driven-development` | Write tests before implementation code |
| 4E.2 | `/tdd-workflow` | ECC: TDD with 80%+ coverage (unit, integration, E2E) |
| 4E.3 | `/tdd` | ECC: scaffold interfaces, generate tests FIRST, then implement |
| 4E.4 | `/python-testing` | Python TDD with pytest, fixtures, mocking, parametrization |
| 4E.5 | `/kotlin-testing` | Kotlin TDD with Kotest, MockK, coroutine testing |
| 4E.6 | `/django-tdd` | Django TDD with pytest-django, factory_boy |
| 4E.7 | `/laravel-tdd` | Laravel TDD with PHPUnit/Pest |
| 4E.8 | `/springboot-tdd` | Spring Boot TDD with JUnit 5, Mockito, Testcontainers |
| 4E.9 | `/rust-test` | Rust TDD with cargo-llvm-cov |
| 4E.10 | `/go-test` | Go TDD with table-driven tests |
| 4E.11 | `/kotlin-test` | Kotlin TDD with Kotest + Kover |
| 4E.12 | `/cpp-test` | C++ TDD with GoogleTest |
| 4E.13 | `/perl-testing` | Perl TDD with Test2::V0 |

### Safety During Implementation
| Step | Command | What it does |
|------|---------|--------------|
| 4F.1 | `/careful` | Warn before destructive commands (rm -rf, DROP TABLE, force-push) |
| 4F.2 | `/freeze` | Lock edits to one directory |
| 4F.3 | `/guard` | Maximum safety: `/careful` + `/freeze` combined |
| 4F.4 | `/unfreeze` | Remove freeze boundary |

### During Implementation (any strategy)
| Command | What it does |
|---------|--------------|
| Context7 `query-docs` | Look up library docs while coding |
| `/docs` | Quick doc lookup via Context7 |
| `/microsoft-docs:microsoft-code-reference` | Verify MS API signatures, catch hallucinated methods |
| Task Master `set_task_status` / `next_task` | Track progress |
| `/gsd:note` | Zero-friction idea capture |
| `/gsd:add-todo` | Add task from conversation context |
| `/gsd:check-todos` | List pending todos, select one to work on |
| `/gsd:progress` | Check project progress, route to next action |
| `/gsd:next` | Auto-advance to next logical step |
| `/aside` | Answer a quick side question without losing context |
| `/checkpoint` | Save checkpoint of current state |
| `/save-session` | Save session state to ~/.claude/sessions/ for later resume |
| `/gsd:pause-work` | Create context handoff when pausing mid-phase |
| `/gsd:thread` | Manage persistent context threads for cross-session work |
| ClickUp `clickup_update_task` | Update task status in ClickUp |
| ClickUp `clickup_start_time_tracking` | Start time tracking |

### Language-Specific Patterns (use during implementation)
| Command | What it does |
|---------|--------------|
| `/coding-standards` | Universal standards for TypeScript, JavaScript, React, Node.js |
| `/frontend-patterns` | React, Next.js, state management, performance |
| `/backend-patterns` | Node.js, Express, Next.js API routes architecture |
| `/api-design` | REST API design — naming, status codes, pagination, errors, versioning |
| `/python-patterns` | Pythonic idioms, PEP 8, type hints |
| `/django-patterns` | Django architecture, DRF, ORM, caching, middleware |
| `/springboot-patterns` | Spring Boot REST, layered services, data access, caching |
| `/java-coding-standards` | Java coding standards for Spring Boot services |
| `/laravel-patterns` | Laravel routing, Eloquent, service layers, queues, events |
| `/mcp-server-patterns` | Build MCP servers with Node/TypeScript SDK |
| `/e2e-testing` | Playwright E2E testing patterns, Page Object Model |
| `/ai-regression-testing` | Regression testing for AI-assisted development |

### Build Error Resolution (spawn fix agent when builds break)
| Command | What it does |
|---------|--------------|
| `/build-fix` | ECC: general build and fix |
| `/go-build` | Fix Go build errors, vet warnings, linter issues |
| `/kotlin-build` | Fix Kotlin/Gradle build errors |
| `/cpp-build` | Fix C++ build errors, CMake/linker issues |
| `/rust-build` | Fix Rust borrow checker, dependency issues |
| `/gradle-build` | Fix Gradle build errors for Android/KMP |

**Output:** Working code, passing tests, atomic commits.

---

## Phase 5: Debugging

**Goal:** Fix issues systematically — no guessing, root cause first.

### Agent Strategy
```
Lead Agent
├── Debug Agent 1 → /investigate (gstack: 4-phase root cause analysis)
├── Debug Agent 2 → /superpowers:systematic-debugging (structured debugging)
├── Debug Agent 3 → /gsd:debug (persistent debug session)
├── Researcher Agent → Context7 + Tavily: search for known issues, similar bugs
└── Lead compares all three diagnoses → picks best root cause → applies fix
```

### Primary (spawn all three for cross-checking)
| Step | Command | What it does |
|------|---------|--------------|
| 5.1 | `/investigate` | gstack: 4-phase root cause analysis (investigate → analyze → hypothesize → implement). Iron law: no fixes without root cause |
| 5.2 | `/superpowers:systematic-debugging` | superpowers: structured debugging before proposing fixes |
| 5.3 | `/gsd:debug` | GSD: persistent debug sessions across context resets |

### Safety
| Step | Command | What it does |
|------|---------|--------------|
| 5.4 | `/guard` | Maximum safety mode for prod debugging |
| 5.5 | `/careful` | Warn before destructive operations |
| 5.6 | `/freeze` | Lock edits to the buggy module only |

**Output:** Root cause identified (cross-verified by 3 agents), fix applied, regression test added.

---

## Phase 6: Testing & QA

**Goal:** Verify everything works — functionally, visually, and across browsers.

### Agent Strategy
```
Lead Agent
├── Unit Test Agent → /tdd or language-specific test command
├── E2E Test Agent → /e2e (Playwright)
├── QA Browser Agent → /qa (headless browser test + auto-fix)
├── Visual QA Agent → /design-review (spacing, hierarchy, AI slop)
├── Verification Agent → /superpowers:verification-before-completion
└── Lead collects all reports → /gsd:audit-uat for final cross-phase check
```

### Automated Testing (spawn per test type)
| Step | Command | What it does |
|------|---------|--------------|
| 6.1 | `/gsd:add-tests` | Generate tests based on UAT criteria and implementation |
| 6.2 | `/tdd` | Scaffold + generate tests with 80%+ coverage |
| 6.3 | `/test-coverage` | Check and improve test coverage |
| 6.4 | `/e2e` | Generate and run Playwright E2E tests with screenshots/videos/traces |
| 6.5 | `/gsd:validate-phase` | Retroactively audit and fill validation gaps for a completed phase |

### Web QA (headless browser)
| Step | Command | What it does |
|------|---------|--------------|
| 6.6 | `/qa` | Full QA: test site + auto-fix bugs + before/after health scores. 3 tiers: Quick, Standard, Exhaustive |
| 6.7 | `/qa-only` | Report-only: bug report with screenshots and repro steps, no fixes |
| 6.8 | `/browse` | Manual headless browser testing — navigate, click, fill, screenshot, assert |
| 6.9 | `/setup-browser-cookies` | Import real browser cookies for authenticated page testing |

### Visual QA (spawn visual reviewer agent)
| Step | Command | What it does |
|------|---------|--------------|
| 6.10 | `/design-review` | Designer's eye QA: spacing, hierarchy, AI slop, slow interactions — then fixes them with before/after screenshots |
| 6.11 | `/gsd:ui-review` | Retroactive 6-pillar visual audit of implemented frontend code |

### Verification (spawn verification agents)
| Step | Command | What it does |
|------|---------|--------------|
| 6.12 | `/gsd:verify-work` | Conversational UAT validation |
| 6.13 | `/superpowers:verification-before-completion` | Evidence-based verification — run commands, confirm output before claiming done |
| 6.14 | `/gsd:audit-uat` | Cross-phase audit of ALL outstanding UAT and verification items |
| 6.15 | `/verify` | ECC: verification command |
| 6.16 | `/eval` | ECC: formal evaluation framework (eval-driven development) |

### Framework-Specific Verification (spawn per framework)
| Step | Command | What it does |
|------|---------|--------------|
| 6.17 | `/springboot-verification` | Spring Boot: build, static analysis, tests, security scans, diff review |
| 6.18 | `/django-verification` | Django: migrations, linting, tests, security scans, deployment readiness |
| 6.19 | `/laravel-verification` | Laravel: env, linting, static analysis, tests, security scans |

**Output:** All tests passing, QA report, visual audit, UAT sign-off — from multiple parallel QA agents.

---

## Phase 7: Code Review

**Goal:** Catch issues before merging. Multiple reviewers for maximum coverage.

### Agent Strategy
```
Lead Agent
├── Review Agent 1 → /review (gstack: SQL safety, trust boundaries, side effects)
├── Review Agent 2 → /code-review (ECC: general review)
├── Review Agent 3 → /codex (adversarial — tries to break your code)
├── Review Agent 4 → Language-specific review (/python-review, /rust-review, etc.)
├── Review Agent 5 → /gsd:review (cross-AI peer review)
└── Lead synthesizes all reviews → addresses feedback → /quality-gate final check
```

### Internal Review (spawn in parallel)
| Step | Command | What it does |
|------|---------|--------------|
| 7.1 | `/review` | gstack: pre-landing diff review — SQL safety, LLM trust boundaries, conditional side effects |
| 7.2 | `/superpowers:requesting-code-review` | superpowers: verify work meets requirements |
| 7.3 | `/gsd:review` | GSD: cross-AI peer review from external AI CLIs |
| 7.4 | `/code-review` | ECC: code review command |
| 7.5 | `/simplify` | Review changed code for reuse, quality, efficiency — fix issues found |

### Adversarial / Second Opinion
| Step | Command | What it does |
|------|---------|--------------|
| 7.6 | `/codex` | OpenAI Codex adversarial review — 3 modes: review (pass/fail), challenge (try to break it), consult (ask anything) |

### Language-Specific Review (spawn per language used)
| Step | Command | What it does |
|------|---------|--------------|
| 7.7 | `/python-review` | PEP 8, type hints, security, Pythonic idioms |
| 7.8 | `/rust-review` | Ownership, lifetimes, error handling, unsafe, idioms |
| 7.9 | `/go-review` | Idiomatic patterns, concurrency safety, error handling |
| 7.10 | `/kotlin-review` | Idiomatic patterns, null safety, coroutine safety |
| 7.11 | `/cpp-review` | Memory safety, modern C++, concurrency, security |

### Quality & Standards
| Step | Command | What it does |
|------|---------|--------------|
| 7.12 | `/quality-gate` | ECC: quality gate enforcement |
| 7.13 | `/refactor-clean` | ECC: refactor and clean code |
| 7.14 | `/verification-loop` | ECC: comprehensive verification system |

### Handling Review Feedback
| Step | Command | What it does |
|------|---------|--------------|
| 7.15 | `/superpowers:receiving-code-review` | Handle code review feedback with technical rigor — verify before implementing suggestions |

**Output:** Clean diff, all review feedback addressed, quality gate passed — verified by 5+ parallel reviewers.

---

## Phase 8: Ship & Deploy

**Goal:** Get it live.

### Agent Strategy
```
Lead Agent
├── Pre-Ship Audit Agent → /gsd:audit-milestone + /gsd:audit-uat
├── Ship Agent → /ship or /gsd:ship (runs tests, bumps version, creates PR)
└── Lead verifies PR is clean → merges
```

### Ship
| Step | Command | What it does |
|------|---------|--------------|
| 8.1 | `/ship` | gstack: full ship workflow — merge base, tests, diff review, VERSION bump, CHANGELOG, commit, push, create PR |
| 8.2 | `/gsd:ship` | GSD: create PR, run review, prepare for merge |
| 8.3 | `/gsd:pr-branch` | Create clean PR branch filtering out .planning/ commits |
| 8.4 | `/superpowers:finishing-a-development-branch` | Structured options for merge, PR, or cleanup |

### Pre-Ship Audit
| Step | Command | What it does |
|------|---------|--------------|
| 8.5 | `/gsd:audit-milestone` | Audit milestone completion against original intent before archiving |
| 8.6 | `/gsd:audit-uat` | Final check on all outstanding UAT items |
| 8.7 | `/harness-audit` | ECC: audit the harness configuration |

**Output:** PR created, merged, deployed.

---

## Phase 9: Post-Ship

**Goal:** Document, retrospect, learn, plan next iteration.

### Agent Strategy
```
Lead Agent
├── Docs Agent → /document-release (sync all docs to what shipped)
├── Learning Agent 1 → /learn-eval (extract patterns, self-evaluate)
├── Learning Agent 2 → /continuous-learning-v2 (instinct-based learning)
├── Retro Agent → /retro (weekly retrospective)
└── Lead reviews → /gsd:complete-milestone → /gsd:new-milestone
```

### Documentation (spawn docs agent)
| Step | Command | What it does |
|------|---------|--------------|
| 9.1 | `/document-release` | Sync README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md to match what shipped. Polish CHANGELOG, clean TODOS, bump VERSION |
| 9.2 | `/update-docs` | ECC: update documentation |

### Retrospective & Reporting
| Step | Command | What it does |
|------|---------|--------------|
| 9.3 | `/retro` | Weekly engineering retrospective — commit history, work patterns, code quality, per-person breakdown |
| 9.4 | `/gsd:session-report` | Token usage estimates, work summary, outcomes |
| 9.5 | `/gsd:stats` | Project statistics — phases, plans, requirements, git metrics, timeline |

### Learning & Pattern Extraction (spawn learning agents in parallel)
| Step | Command | What it does |
|------|---------|--------------|
| 9.6 | `/learn` | Extract reusable patterns from the session |
| 9.7 | `/learn-eval` | Extract patterns + self-evaluate quality before saving |
| 9.8 | `/continuous-learning` | Auto-extract patterns and save as learned skills |
| 9.9 | `/continuous-learning-v2` | Instinct-based learning — observe sessions, create atomic instincts with confidence scoring |
| 9.10 | `/instinct-status` | Show learned instincts with confidence |
| 9.11 | `/instinct-export` | Export instincts to file |
| 9.12 | `/evolve` | Analyze instincts and suggest evolved structures |
| 9.13 | `/skill-create` | Analyze local git history to generate SKILL.md files |
| 9.14 | `/rules-distill` | Scan skills to extract cross-cutting principles into rules |

### Next Iteration
| Step | Command | What it does |
|------|---------|--------------|
| 9.15 | `/gsd:complete-milestone` | Archive milestone, prepare for next version |
| 9.16 | `/gsd:new-milestone` | Start next milestone cycle |
| 9.17 | `/gsd:review-backlog` | Review and promote backlog items to active milestone |
| 9.18 | `/gsd:cleanup` | Archive accumulated phase directories from completed milestones |

### Presentation
| Step | Command | What it does |
|------|---------|--------------|
| 9.19 | Gamma `generate` | Generate release presentation or changelog doc |
| 9.20 | `/frontend-slides` | Create HTML presentation for release |

**Output:** Updated docs, retrospective, learned patterns, next milestone ready.

---

## Session Management (use anytime)

| Command | What it does |
|---------|--------------|
| `/save-session` | Save session state to ~/.claude/sessions/ |
| `/resume-session` | Load most recent session and resume |
| `/gsd:pause-work` | Create context handoff when pausing mid-phase |
| `/gsd:resume-work` | Resume work from previous session with full context |
| `/gsd:thread` | Manage persistent context threads across sessions |
| `/checkpoint` | Save checkpoint |
| `/aside` | Answer side question without losing context |
| `/strategic-compact` | Suggest manual context compaction at logical intervals |
| `/context-budget` | Analyze context window usage — find optimization opportunities |
| `/claw` | Start NanoClaw REPL — persistent, model routing, branching, compaction |

---

## Skill & Plugin Management

| Command | What it does |
|---------|--------------|
| `/superpowers:writing-skills` | Create or edit custom skills |
| `/skill-create` | Generate SKILL.md from git history patterns |
| `/skill-stocktake` | Audit skills for quality (quick scan or full) |
| `/skill-health` | Skill portfolio health dashboard with analytics |
| `/configure-ecc` | Interactive ECC installer — select and install skills/rules |
| `/gsd:update` | Update GSD to latest version |
| `/gstack-upgrade` | Upgrade gstack to latest version |
| `/gsd:reapply-patches` | Reapply local modifications after GSD update |
| `/gsd:health` | Diagnose planning directory health, optionally repair |

---

## MCP Servers (available in all phases)

| Server | Tools | Use for |
|--------|-------|---------|
| **Tavily** | `tavily_search`, `tavily_extract`, `tavily_crawl`, `tavily_research`, `tavily_map` | Web search, page extraction, site crawling, deep research |
| **Context7** | `resolve-library-id`, `query-docs` | Up-to-date library/framework documentation |
| **Microsoft Learn** | `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search` | Azure, .NET, M365, Windows docs and code samples |
| **ClickUp** | 40+ tools (tasks, lists, folders, docs, time tracking, chat, reminders) | Project management, time tracking, team collaboration |
| **Gamma** | `generate`, `get_themes`, `get_folders`, `get_generation_status` | AI-generated presentations, documents, webpages |
| **Task Master AI** | `get_tasks`, `next_task`, `set_task_status`, `parse_prd`, `expand_task`, `add_task`, etc. | AI-powered task breakdown and tracking |

---

## Quick Decision Guide

| Situation | Primary | Cross-Check With |
|-----------|---------|-----------------|
| New idea | `/office-hours` | `/superpowers:brainstorming` |
| New project | `/gsd:new-project` | `/plan` |
| Plan a phase | `/gsd:plan-phase` | `/superpowers:writing-plans`, `/plan` |
| Review plan (strategy) | `/plan-ceo-review` | `/plan-eng-review` |
| Review plan (architecture) | `/plan-eng-review` | `/plan-ceo-review` |
| Review plan (design) | `/plan-design-review` | `/design-consultation` |
| Build (team) | `/build-with-agent-team` | `/devfleet`, `/orchestrate` |
| Build (solo) | `/gsd:execute-phase` | `/superpowers:executing-plans` |
| Build (auto) | `/gsd:autonomous` | — |
| Quick task | `/gsd:fast` | `/gsd:quick` |
| Debug | `/investigate` | `/superpowers:systematic-debugging`, `/gsd:debug` |
| Test site | `/qa` | `/browse`, `/e2e` |
| Visual QA | `/design-review` | `/gsd:ui-review` |
| Code review | `/review` | `/codex`, `/code-review`, language-specific reviews |
| Ship | `/ship` | `/gsd:ship` |
| Update docs | `/document-release` | `/update-docs` |
| Retrospective | `/retro` | `/gsd:session-report`, `/gsd:stats` |
| What's next | `/gsd:next` | `/gsd:progress` |
| Safety mode | `/guard` | `/careful` + `/freeze` separately |
| Research tech | Context7 + Tavily (parallel agents) | Microsoft Learn (for MS tech) |
| Verify done | `/superpowers:verification-before-completion` | `/gsd:verify-work`, `/verify` |
