# Decision Matrix — When to Use Agent Team

Quick assessment to decide: **Agent Team** vs **Solo Build** vs **Template Deploy**.

---

## Complexity Scoring

Score each dimension (0-2 points):

| Dimension | 0 pts (Simple) | 1 pt (Medium) | 2 pts (Complex) |
|-----------|-----------------|----------------|------------------|
| **Node count** | 2-4 nodes | 5-8 nodes | 9+ nodes |
| **Integrations** | 1 service | 2-3 services | 4+ services |
| **Branching** | Linear flow | 1 IF/Switch | Multiple branches |
| **AI components** | None | Simple (1 model) | Agent + tools + memory |
| **Error handling** | None needed | Basic (continueOnFail) | Error workflows + retry |
| **Data transforms** | Direct mapping | Set/Code nodes | Complex multi-step |

### Decision Thresholds

| Total Score | Approach | Rationale |
|-------------|----------|-----------|
| **0-3** | **Solo Build** | Simple enough for direct MCP calls |
| **4-7** | **Agent Team** | Complexity benefits from parallel research + validation |
| **8-12** | **Agent Team (mandatory)** | Too complex for reliable single-agent build |

---

## Quick Decision Tree

```
User request received
    |
    ├── "Deploy template X" or "use template for Y"
    |   └── TEMPLATE DEPLOY (n8n_deploy_template)
    |
    ├── Simple trigger + 1-3 actions, no branching
    |   └── SOLO BUILD (direct MCP calls)
    |
    ├── 5+ nodes OR multi-branch OR AI agent
    |   └── AGENT TEAM
    |
    └── Unsure?
        └── Score using matrix above
```

---

## Examples by Approach

### Solo Build (score 0-3)
- Gmail trigger → create draft reply (2 nodes)
- Webhook → Slack notification (2-3 nodes)
- Schedule → HTTP Request → Google Sheet (3 nodes)
- Form trigger → Email confirmation (2 nodes)

### Agent Team (score 4-7)
- Email received → AI categorize → route to different Slack channels (5-6 nodes)
- Webhook → validate data → IF conditions → Database + Slack (6-7 nodes)
- Schedule → fetch API → transform → IF error → Slack alert + Database (6 nodes)
- GitHub webhook → analyze PR → post review comment (5 nodes with AI)

### Agent Team Mandatory (score 8-12)
- AI Agent with tools + memory handling customer support via email/chat (8+ nodes)
- Multi-step lead qualification: receive form → enrich with API → score → CRM + Slack + Email (9+ nodes)
- Data pipeline: Schedule → multiple APIs → merge → transform → Database → report → Email + Slack (10+ nodes)
- AI content pipeline: trigger → research → generate → review → multi-platform publish (10+ nodes)

---

## Existing Workflow Modifications

For modifying existing workflows, the decision is simpler:

| Change Type | Approach |
|-------------|----------|
| Add 1-2 nodes | Solo (`n8n_update_partial_workflow`) |
| Fix validation errors | Solo (`n8n_autofix_workflow`) |
| Add new branch with 3+ nodes | Agent Team |
| Major restructure (5+ changes) | Agent Team |
| Replace nodes + update connections | Agent Team |

---

## Cost-Benefit Summary

### Solo Build
- **Cost**: Lower token usage, faster for simple tasks
- **Risk**: May miss edge cases, no parallel research
- **Best for**: Quick automations, single-integration workflows

### Agent Team
- **Cost**: Higher token usage (3 agents), coordination overhead
- **Benefit**: Parallel research (2-3x faster for complex nodes), systematic validation, fewer errors
- **Best for**: Production workflows, multi-integration systems, AI-powered automations

### Template Deploy
- **Cost**: Minimal (single API call)
- **Benefit**: Proven patterns, instant setup
- **Limitation**: Requires matching template to exist
- **Best for**: Common patterns (webhook→Slack, schedule→email, etc.)
