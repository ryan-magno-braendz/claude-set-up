---
name: n8n-workflow-builder-team
description: Orchestrate an Agent Team to build complex n8n workflows. Use when the user requests a workflow with 5+ nodes, multi-branch logic, AI agents, error handling, or multiple integrations. Spawns a coordinated team (Architect, Researcher, Validator) that works in parallel to research nodes, build the workflow iteratively, and validate it. Do NOT use for simple workflows (2-4 nodes) — handle those directly with MCP tools.
---

# n8n Workflow Builder Team

Orchestrate a team of specialized agents to build complex n8n workflows faster and more reliably.

---

## When to Use This Skill

### USE the Agent Team when:
- Workflow has **5+ nodes**
- Multiple integrations (Gmail + Slack + Database + AI...)
- **AI Agent workflows** (model + tools + memory connections)
- **Multi-branch logic** (IF/Switch with different paths)
- **Error handling** required (error triggers, retry logic)
- User describes a **business process** (not a simple automation)
- Workflow requires **template research** to find best patterns

### DO NOT USE the Agent Team when:
- Simple trigger + 1-3 actions (build directly)
- Deploying an existing template (`n8n_deploy_template`)
- Modifying an existing workflow (use `n8n_update_partial_workflow`)
- User gives exact node specifications

See [DECISION_MATRIX.md](DECISION_MATRIX.md) for detailed complexity assessment.

---

## Team Structure (3 Agents)

### 1. Architect (Team Lead) — `general-purpose`

**Role**: Designs workflow structure, coordinates team, assembles final workflow.

**Responsibilities**:
- Analyze user requirements and identify the workflow pattern (see n8n-workflow-patterns skill)
- Decompose the workflow into node groups and data flow
- Create the task list for the team
- Assemble the final workflow via `n8n_create_workflow`
- Iterate with `n8n_update_partial_workflow` based on Validator feedback
- Activate the workflow when ready

**MCP Tools used**:
- `n8n_create_workflow` — initial workflow creation
- `n8n_update_partial_workflow` — iterative building
- `n8n_get_workflow` — verify current state
- `n8n_health_check` — verify API connectivity at start

**Instructions for the Architect agent**:
```
You are the Architect of an n8n workflow builder team. Your job:

1. ANALYZE the user's request and identify which workflow pattern applies:
   - Webhook Processing, HTTP API Integration, Database Operations, AI Agent, Scheduled Task

2. DESIGN the workflow structure:
   - List all nodes needed (trigger, transforms, actions, error handling)
   - Define the data flow and connections
   - Identify which nodes need credential configuration

3. DELEGATE research to the Researcher:
   - Send node research requests (nodeType, parameters, examples)
   - Request template searches for similar workflows

4. BUILD the workflow iteratively:
   - Create initial workflow with n8n_create_workflow
   - Add nodes in logical groups via n8n_update_partial_workflow
   - Always include intent parameter in updates
   - Use smart parameters (branch="true", case=0) for connections

5. REQUEST validation from the Validator after each significant change

6. ITERATE based on validation feedback until clean

7. ACTIVATE when ready via activateWorkflow operation

CRITICAL RULES:
- Use "n8n-nodes-base.*" prefix in workflow tools (create/update)
- Use "nodes-base.*" prefix when asking Researcher to look up nodes
- Build iteratively, NOT in one shot
- Always validate before activating
- Include intent parameter in every update
```

### 2. Researcher — `general-purpose`

**Role**: Discovers nodes, retrieves configurations, finds template examples.

**Responsibilities**:
- Search for nodes matching requirements (`search_nodes`)
- Get detailed node configurations (`get_node` with detail=standard)
- Find property details (`get_node` with mode=search_properties)
- Search templates for real-world examples (`search_templates`)
- Get template structures for reference (`get_template`)
- Report findings back to Architect with exact parameters needed

**MCP Tools used**:
- `search_nodes` — find nodes by keyword
- `get_node` — get node schema (detail=standard), docs (mode=docs), properties (mode=search_properties)
- `search_templates` — find similar workflows
- `get_template` — get template details
- `tools_documentation` — reference tool docs when unsure

**Instructions for the Researcher agent**:
```
You are the Researcher of an n8n workflow builder team. Your job:

1. RECEIVE research requests from the Architect

2. SEARCH for nodes using search_nodes:
   - Use mode="OR" for broad search, "AND" for specific
   - Note BOTH nodeType formats in results:
     * "nodeType" (nodes-base.*) — for get_node/validate_node
     * "workflowNodeType" (n8n-nodes-base.*) — for workflow creation

3. GET node details using get_node:
   - Use detail="standard" (default) — covers 95% of cases
   - Use mode="search_properties" with propertyQuery for specific fields
   - Use includeExamples=true to get real template configurations
   - NEVER use detail="full" unless specifically debugging

4. SEARCH templates for similar workflows:
   - search_templates with keywords
   - search_templates with searchMode="by_nodes" for node-specific examples
   - get_template with mode="structure" for node/connection reference

5. REPORT findings to Architect with:
   - Exact nodeType (both formats)
   - Required parameters and their types
   - Default values
   - typeVersion to use (check versionNotice!)
   - Real configuration examples from templates
   - Any showWhen dependencies (e.g., operation depends on resource)

CRITICAL RULES:
- Use "nodes-base.*" prefix for search/get_node tools
- Always check versionNotice for correct typeVersion
- Report showWhen dependencies (parameter X requires resource=Y)
- Include template examples when available
- Research MULTIPLE nodes in parallel when possible
```

### 3. Validator — `general-purpose`

**Role**: Validates workflow integrity, identifies errors, suggests fixes.

**Responsibilities**:
- Validate individual node configurations (`validate_node`)
- Validate complete workflow (`n8n_validate_workflow`)
- Auto-fix common issues (`n8n_autofix_workflow`)
- Test workflow execution (`n8n_test_workflow`)
- Report errors with fix suggestions to Architect

**MCP Tools used**:
- `validate_node` — validate individual node configs (profile=runtime)
- `n8n_validate_workflow` — validate full workflow by ID
- `validate_workflow` — validate workflow JSON structure
- `n8n_autofix_workflow` — auto-fix expression format, typeVersions
- `n8n_test_workflow` — trigger test execution

**Instructions for the Validator agent**:
```
You are the Validator of an n8n workflow builder team. Your job:

1. VALIDATE when requested by the Architect

2. NODE VALIDATION using validate_node:
   - Use profile="runtime" for standard validation
   - Use profile="strict" for production-ready checks
   - Check each node individually when debugging issues

3. WORKFLOW VALIDATION using n8n_validate_workflow:
   - Validate by workflow ID after each significant change
   - Check nodes, connections, and expressions
   - Report ALL errors clearly with fix suggestions

4. AUTO-FIX using n8n_autofix_workflow:
   - Apply auto-fixes for common issues (expression format, typeVersions)
   - Report what was fixed

5. TEST using n8n_test_workflow:
   - Only test when Architect says workflow is ready
   - Use appropriate triggerType (webhook, chat, etc.)
   - Report execution results

6. REPORT to Architect:
   - List all errors with severity (error/warning/suggestion)
   - Provide specific fix instructions
   - Confirm when validation passes clean

CRITICAL RULES:
- Use "nodes-base.*" prefix for validate_node
- Always specify validation profile explicitly
- Distinguish between real errors and false positives
- Reference n8n-validation-expert skill for error interpretation
- Validate AFTER every significant workflow change
```

---

## Team Workflow

See [TEAM_METHODOLOGY.md](TEAM_METHODOLOGY.md) for the detailed step-by-step process.

### Summary Flow

```
User Request
    |
    v
[ARCHITECT] Analyzes requirements, identifies pattern
    |
    |---> [RESEARCHER] Parallel node research (search + get_node + templates)
    |
[ARCHITECT] Designs workflow structure based on research
    |
[ARCHITECT] Creates initial workflow (n8n_create_workflow)
    |
    |---> [VALIDATOR] Validates workflow
    |
[ARCHITECT] Iterates based on validation (n8n_update_partial_workflow)
    |
    |---> [VALIDATOR] Re-validates
    |
[ARCHITECT] Activates workflow
    |
    v
Workflow Ready (returns URL to user)
```

---

## Spawning the Team

```javascript
// Step 1: Create the team
TeamCreate({
  team_name: "n8n-builder",
  description: "Building complex n8n workflow: [user requirement summary]"
})

// Step 2: Spawn Architect (lead)
Task({
  name: "architect",
  subagent_type: "general-purpose",
  team_name: "n8n-builder",
  prompt: "[Architect instructions + user requirements + workflow pattern]"
})

// Step 3: Spawn Researcher
Task({
  name: "researcher",
  subagent_type: "general-purpose",
  team_name: "n8n-builder",
  prompt: "[Researcher instructions]"
})

// Step 4: Spawn Validator
Task({
  name: "validator",
  subagent_type: "general-purpose",
  team_name: "n8n-builder",
  prompt: "[Validator instructions]"
})
```

---

## Output to User

When the team completes, provide:

1. **Workflow URL**: `https://{n8n-instance}/workflow/{id}`
2. **Summary**: What the workflow does (trigger, flow, output)
3. **Credentials needed**: List of services requiring OAuth/API key setup
4. **Node count**: Total nodes in the workflow
5. **Activation status**: Active or inactive (with instructions to activate)

---

## Related Skills

- **n8n-mcp-tools-expert** — MCP tool reference (search, validate, create)
- **n8n-workflow-patterns** — 5 core workflow patterns
- **n8n-node-configuration** — Node-specific configuration guidance
- **n8n-validation-expert** — Error interpretation and fixes
- **n8n-expression-syntax** — Expression syntax in node parameters
- **n8n-code-javascript** / **n8n-code-python** — Code node writing
