# n8n Architect - Claude Agent Skill

Welcome! You've downloaded the official n8n workflow development skill for Claude.

## 🚀 Quick Installation

### For Claude.ai

1. In Claude.ai, go to **Settings → Features**
2. Under "Custom Skills", click **Upload Skill**
3. Upload the `n8n-architect` folder as a ZIP file
4. Done! Claude will now use this skill automatically when discussing n8n workflows

### For Claude Code

1. Copy the `n8n-architect/` folder to your project:
   ```bash
   cp -r n8n-architect /path/to/your/project/.claude/skills/
   ```

2. Or install globally:
   ```bash
   cp -r n8n-architect ~/.claude/skills/
   ```

3. Claude Code will auto-discover the skill

## ✨ What This Skill Does

When installed, Claude becomes an expert n8n developer who can:

- ✅ Search for n8n nodes by name or functionality
- ✅ Retrieve exact node schemas and parameters
- ✅ Generate valid workflow JSON without hallucinating
- ✅ Follow n8n best practices and modern syntax
- ✅ Help debug and improve existing workflows

## 🔍 How It Works

The skill uses the `@n8n-as-code/skills` package (formerly skills) to access complete n8n node documentation:

```bash
npx -y @n8n-as-code/skills search "http request"
npx -y @n8n-as-code/skills get "httpRequest"
npx -y @n8n-as-code/skills list
```

Claude executes these commands automatically when you ask about n8n workflows.

## 🔒 Privacy & Security

This skill runs **100% locally**:
- No data sent to external servers
- NPX downloads the tool on first use
- All documentation accessed offline

## 📚 Documentation

Full documentation: https://github.com/EtienneLescot/n8n-as-code

## 🤝 Support

Issues or questions? Visit: https://github.com/EtienneLescot/n8n-as-code/issues

## 📄 License

MIT License - Part of the n8n-as-code project
