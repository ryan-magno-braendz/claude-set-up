# Team Methodology — Step-by-Step Process

Detailed process for the Agent Team to build complex n8n workflows.

---

## Phase 1: Requirements Analysis (Architect solo)

**Duration**: 1 turn

1. Parse user request into structured requirements:
   - **Trigger**: What starts the workflow? (email, webhook, schedule, chat...)
   - **Inputs**: What data sources are involved?
   - **Logic**: Any conditions, branching, loops?
   - **Outputs**: What actions should happen? (send email, update DB, notify Slack...)
   - **Error handling**: What happens on failure?

2. Identify the **workflow pattern** (from n8n-workflow-patterns skill):
   - Webhook Processing
   - HTTP API Integration
   - Database Operations
   - AI Agent Workflow
   - Scheduled Task
   - Or a **hybrid** combining multiple patterns

3. Produce a **node list** (estimated):
   ```
   Example: "AI email responder"
   - Gmail Trigger (receive email)
   - AI Agent (generate response)
     - OpenAI Chat Model (ai_languageModel)
     - Window Buffer Memory (ai_memory)
   - Gmail (create draft reply)
   - Error handling nodes
   Total: ~6 nodes
   ```

4. Create the **task list** and delegate to Researcher.

---

## Phase 2: Parallel Research (Researcher)

**Duration**: 1-3 turns (runs while Architect designs)

The Researcher executes these tasks **in parallel** when possible:

### Task A: Node Discovery
For each node in the Architect's list:
```
1. search_nodes({query: "keyword"})
   → Get nodeType and workflowNodeType

2. get_node({nodeType: "nodes-base.xxx", detail: "standard"})
   → Get operations, required parameters, typeVersion

3. get_node({nodeType: "nodes-base.xxx", mode: "search_properties", propertyQuery: "specific_field"})
   → Get specific property details when needed
```

### Task B: Template Research
Find similar workflows for reference:
```
1. search_templates({query: "relevant keywords", limit: 5})
   → Find similar workflows

2. get_template({templateId: xxx, mode: "structure"})
   → Get node configurations and connections as reference
```

### Task C: Version Check
For each node:
```
get_node({nodeType: "nodes-base.xxx", mode: "versions"})
→ Confirm correct typeVersion (check versionNotice!)
```

### Research Report Format
Report to Architect with this structure per node:
```
NODE: Gmail Trigger
- workflowNodeType: "n8n-nodes-base.gmailTrigger"
- typeVersion: 1.3
- Required params: none (event defaults to "messageReceived")
- Optional params: filters (sender, labels, readStatus)
- Credentials: Gmail OAuth2
- Output fields: id, threadId, from, to, subject, snippet, body, date
- Template reference: Template #1234 uses similar config
```

---

## Phase 3: Workflow Assembly (Architect)

**Duration**: 2-4 turns

### Step 1: Create Base Workflow
```javascript
n8n_create_workflow({
  name: "Descriptive Workflow Name",
  nodes: [
    // Start with trigger + first 2-3 core nodes only
  ],
  connections: {
    // Connect the initial nodes
  },
  settings: {
    executionOrder: "v1"  // Always use v1
  }
})
```

**Rules**:
- Create workflow with **minimal nodes first** (trigger + core path)
- Use `n8n-nodes-base.*` prefix for node types
- Position nodes on a grid: x increments of 250, y increments of 200
- Connection keys use **node names** (not IDs)

### Step 2: Iterative Node Addition
Add remaining nodes in logical groups:
```javascript
n8n_update_partial_workflow({
  id: "workflow-id",
  intent: "Add AI agent with model and memory connections",
  operations: [
    {type: "addNode", node: {...}},
    {type: "addNode", node: {...}},
    {type: "addConnection", source: "...", target: "...", sourceOutput: "ai_languageModel"},
    {type: "addConnection", source: "...", target: "...", sourceOutput: "ai_memory"}
  ]
})
```

**Group additions logically**:
- Group 1: Core data path (trigger → main action)
- Group 2: Transformation nodes (Set, Code, IF)
- Group 3: AI components (model, tools, memory)
- Group 4: Error handling (Error Trigger, notification)
- Group 5: Secondary outputs (logging, notifications)

### Step 3: Request Validation
After each group, send to Validator.

---

## Phase 4: Validation Loop (Validator)

**Duration**: 1-3 turns per cycle

### Step 1: Full Workflow Validation
```javascript
n8n_validate_workflow({
  id: "workflow-id",
  options: {
    validateNodes: true,
    validateConnections: true,
    validateExpressions: true,
    profile: "runtime"
  }
})
```

### Step 2: Individual Node Validation (if errors found)
```javascript
validate_node({
  nodeType: "nodes-base.xxx",
  config: { /* node parameters */ },
  profile: "runtime"
})
```

### Step 3: Auto-Fix Attempt
```javascript
n8n_autofix_workflow({id: "workflow-id"})
```

### Step 4: Report to Architect
```
VALIDATION REPORT:
- Errors: [list with fix instructions]
- Warnings: [list with recommendations]
- Clean nodes: [list of passing nodes]
- Auto-fixes applied: [list]
- Remaining manual fixes needed: [list]
```

### Validation Loop
```
Architect builds → Validator checks → Architect fixes → Validator re-checks
Repeat until: 0 errors, acceptable warnings only
```

---

## Phase 5: Finalization (Architect)

**Duration**: 1 turn

1. **Final validation** — one last clean check
2. **Activate workflow** (if user wants it active):
   ```javascript
   n8n_update_partial_workflow({
     id: "workflow-id",
     intent: "Activate workflow for production",
     operations: [{type: "activateWorkflow"}]
   })
   ```
3. **Report to user** with:
   - Workflow URL
   - Node summary
   - Credentials to configure
   - Any manual steps required

---

## Communication Protocol

### Architect → Researcher
```
RESEARCH REQUEST:
Nodes needed: [list of keywords/descriptions]
Priority: [which nodes to research first]
Template search: [keywords for similar workflows]
```

### Researcher → Architect
```
RESEARCH COMPLETE:
[Per-node report as described in Phase 2]
```

### Architect → Validator
```
VALIDATION REQUEST:
Workflow ID: [id]
Changes made: [description of recent changes]
Focus areas: [specific nodes or connections to check]
```

### Validator → Architect
```
VALIDATION REPORT:
Status: PASS / FAIL
Errors: [list]
Fixes needed: [list with specific instructions]
```

---

## Timing Expectations

| Phase | Duration | Agents Active |
|-------|----------|---------------|
| Requirements Analysis | 1 turn | Architect |
| Parallel Research | 1-3 turns | Researcher (+ Architect designing) |
| Workflow Assembly | 2-4 turns | Architect |
| Validation Loop | 1-3 cycles | Validator + Architect |
| Finalization | 1 turn | Architect |
| **Total** | **~6-12 turns** | |

---

## Error Recovery

### If Researcher can't find a node:
- Try `search_nodes` with FUZZY mode
- Search templates by task type: `search_templates({searchMode: "by_task", task: "..."})`
- Fall back to `n8n-nodes-base.httpRequest` for custom API calls

### If Validation fails repeatedly:
- Validator should use `validate_node` on individual nodes to isolate the issue
- Check for showWhen dependency issues (operation requires specific resource value)
- Try `n8n_autofix_workflow` for expression and version fixes
- As last resort, Architect recreates the problematic node

### If Workflow creation fails:
- Run `n8n_health_check({mode: "diagnostic"})` to check API connectivity
- Verify all node types exist via `search_nodes`
- Create with minimal nodes first, then add incrementally
