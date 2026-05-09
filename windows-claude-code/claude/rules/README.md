# Rules

Behavioral and conventional rules layered with the global `~/.claude/CLAUDE.md`.

## Structure

```
rules/
├── common/          # Language-agnostic — always loaded
└── <language>/      # Path-scoped — only loads near matching files
```

`common/` rules apply universally. Language-specific rules (typescript, python, rust, java, csharp, cpp) load only when working in matching files (via `paths:` frontmatter).

When language-specific rules conflict with common rules, language-specific wins.
