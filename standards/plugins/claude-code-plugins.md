# Claude Code Plugins Reference

> **Source**: https://code.claude.com/docs/en/plugins-reference
> **Date**: 2026-02-25
> **Purpose**: 开发 Claude Code 插件（Skills、Agents、Hooks、MCP Servers、LSP Servers）时必须遵循的规范

---

## Overview

A **plugin** is a self-contained directory of components that extends Claude Code with custom functionality. Plugin components include skills, agents, hooks, MCP servers, and LSP servers.

---

## Plugin Components Reference

### Skills

Plugins add skills to Claude Code, creating `/name` shortcuts that you or Claude can invoke.

**Location**: `skills/` or `commands/` directory in plugin root
**File format**: Skills are directories with `SKILL.md`; commands are simple markdown files

**Skill structure**:
```
skills/
├── pdf-processor/
│   ├── SKILL.md
│   ├── reference.md (optional)
│   └── scripts/ (optional)
└── code-reviewer/
    └── SKILL.md
```

**Integration behavior**:
- Skills and commands are automatically discovered when the plugin is installed
- Claude can invoke them automatically based on task context
- Skills can include supporting files alongside SKILL.md

### Agents

Plugins can provide specialized subagents for specific tasks that Claude can invoke automatically when appropriate.

**Location**: `agents/` directory in plugin root
**File format**: Markdown files describing agent capabilities

**Agent structure**:
```markdown
---
name: agent-name
description: What this agent specializes in and when Claude should invoke it
---

Detailed system prompt for the agent describing its role, expertise, and behavior.
```

**Integration points**:
- Agents appear in the `/agents` interface
- Claude can invoke agents automatically based on task context
- Agents can be invoked manually by users
- Plugin agents work alongside built-in Claude agents

### Hooks

Plugins can provide event handlers that respond to Claude Code events automatically.

**Location**: `hooks/hooks.json` in plugin root, or inline in plugin.json
**Format**: JSON configuration with event matchers and actions

**Hook configuration**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

**Available events**:
| Event | Trigger |
|-------|---------|
| `PreToolUse` | Before Claude uses any tool |
| `PostToolUse` | After Claude successfully uses any tool |
| `PostToolUseFailure` | After Claude tool execution fails |
| `PermissionRequest` | When a permission dialog is shown |
| `UserPromptSubmit` | When user submits a prompt |
| `Notification` | When Claude Code sends notifications |
| `Stop` | When Claude attempts to stop |
| `SubagentStart` | When a subagent is started |
| `SubagentStop` | When a subagent attempts to stop |
| `SessionStart` | At the beginning of sessions |
| `SessionEnd` | At the end of sessions |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `TaskCompleted` | When a task is being marked as completed |
| `PreCompact` | Before conversation history is compacted |

**Hook types**:
- `command`: Execute shell commands or scripts
- `prompt`: Evaluate a prompt with an LLM (uses `$ARGUMENTS` placeholder for context)
- `agent`: Run an agentic verifier with tools for complex verification tasks

### MCP Servers

Plugins can bundle Model Context Protocol (MCP) servers to connect Claude Code with external tools and services.

**Location**: `.mcp.json` in plugin root, or inline in plugin.json
**Format**: Standard MCP server configuration

**MCP server configuration**:
```json
{
  "mcpServers": {
    "plugin-database": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "DB_PATH": "${CLAUDE_PLUGIN_ROOT}/data"
      }
    },
    "plugin-api-client": {
      "command": "npx",
      "args": ["@company/mcp-server", "--plugin-mode"],
      "cwd": "${CLAUDE_PLUGIN_ROOT}"
    }
  }
}
```

**Integration behavior**:
- Plugin MCP servers start automatically when the plugin is enabled
- Servers appear as standard MCP tools in Claude's toolkit
- Server capabilities integrate seamlessly with Claude's existing tools
- Plugin servers can be configured independently of user MCP servers

### LSP Servers

Plugins can provide Language Server Protocol (LSP) servers to give Claude real-time code intelligence while working on your codebase.

LSP integration provides:
- **Instant diagnostics**: Claude sees errors and warnings immediately after each edit
- **Code navigation**: go to definition, find references, and hover information
- **Language awareness**: type information and documentation for code symbols

**Location**: `.lsp.json` in plugin root, or inline in `plugin.json`
**Format**: JSON configuration mapping language server names to their configurations

**`.lsp.json` file format**:
```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

**Required fields**:
| Field | Description |
|-------|-------------|
| `command` | The LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

**Optional fields**:
| Field | Description |
|-------|-------------|
| `args` | Command-line arguments for the LSP server |
| `transport` | Communication transport: `stdio` (default) or `socket` |
| `env` | Environment variables to set when starting the server |
| `initializationOptions` | Options passed to the server during initialization |
| `settings` | Settings passed via `workspace/didChangeConfiguration` |
| `workspaceFolder` | Workspace folder path for the server |
| `startupTimeout` | Max time to wait for server startup (milliseconds) |
| `shutdownTimeout` | Max time to wait for graceful shutdown (milliseconds) |
| `restartOnCrash` | Whether to automatically restart the server if it crashes |
| `maxRestarts` | Maximum number of restart attempts before giving up |

---

## Plugin Installation Scopes

When you install a plugin, you choose a **scope** that determines where the plugin is available and who else can use it:

| Scope | Settings file | Use case |
|-------|---------------|----------|
| `user` | `~/.claude/settings.json` | Personal plugins available across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |
| `managed` | `managed-settings.json` | Managed plugins (read-only, update only) |

---

## Plugin Manifest Schema

The `.claude-plugin/plugin.json` file defines your plugin's metadata and configuration.

### Complete Schema

```json
{
  "name": "plugin-name",
  "version": "1.2.0",
  "description": "Brief plugin description",
  "author": {
    "name": "Author Name",
    "email": "[email protected]",
    "url": "https://github.com/author"
  },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "commands": ["./custom/commands/special.md"],
  "agents": "./custom/agents/",
  "skills": "./custom/skills/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json",
  "outputStyles": "./styles/",
  "lspServers": "./.lsp.json"
}
```

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Unique identifier (kebab-case, no spaces) | `"deployment-tools"` |

### Metadata Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `version` | string | Semantic version | `"2.1.0"` |
| `description` | string | Brief explanation of plugin purpose | `"Deployment automation tools"` |
| `author` | object | Author information | `{"name": "Dev Team", "email": "[email protected]"}` |
| `homepage` | string | Documentation URL | `"https://docs.example.com"` |
| `repository` | string | Source code URL | `"https://github.com/user/plugin"` |
| `license` | string | License identifier | `"MIT"`, `"Apache-2.0"` |
| `keywords` | array | Discovery tags | `["deployment", "ci-cd"]` |

### Component Path Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `commands` | string\|array | Additional command files/directories | `"./custom/cmd.md"` or `["./cmd1.md"]` |
| `agents` | string\|array | Additional agent files | `"./custom/agents/reviewer.md"` |
| `skills` | string\|array | Additional skill directories | `"./custom/skills/"` |
| `hooks` | string\|array\|object | Hook config paths or inline config | `"./my-extra-hooks.json"` |
| `mcpServers` | string\|array\|object | MCP config paths or inline config | `"./my-extra-mcp-config.json"` |
| `outputStyles` | string\|array | Additional output style files/directories | `"./styles/"` |
| `lspServers` | string\|array\|object | LSP configs | `"./.lsp.json"` |

### Path Behavior Rules

**Important**: Custom paths supplement default directories - they don't replace them.

- If `commands/` exists, it's loaded in addition to custom command paths
- All paths must be relative to plugin root and start with `./`
- Commands from custom paths use the same naming and namespacing rules
- Multiple paths can be specified as arrays for flexibility

### Environment Variables

**`${CLAUDE_PLUGIN_ROOT}`**: Contains the absolute path to your plugin directory. Use this in hooks, MCP servers, and scripts to ensure correct paths regardless of installation location.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/process.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Plugin Directory Structure

### Standard Plugin Layout

```
enterprise-plugin/
├── .claude-plugin/           # Metadata directory (optional)
│   └── plugin.json             # plugin manifest
├── commands/                 # Default command location
│   ├── status.md
│   └── logs.md
├── agents/                   # Default agent location
│   ├── security-reviewer.md
│   ├── performance-tester.md
│   └── compliance-checker.md
├── skills/                   # Agent Skills
│   ├── code-reviewer/
│   │   └── SKILL.md
│   └── pdf-processor/
│       ├── SKILL.md
│       └── scripts/
├── hooks/                    # Hook configurations
│   ├── hooks.json           # Main hook config
│   └── security-hooks.json  # Additional hooks
├── settings.json            # Default settings for the plugin
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── scripts/                 # Hook and utility scripts
│   ├── security-scan.sh
│   ├── format-code.py
│   └── deploy.js
├── LICENSE                  # License file
└── CHANGELOG.md             # Version history
```

### File Locations Reference

| Component | Default Location | Purpose |
|-----------|------------------|---------|
| **Manifest** | `.claude-plugin/plugin.json` | Plugin metadata and configuration (optional) |
| **Commands** | `commands/` | Skill Markdown files (legacy; use `skills/` for new skills) |
| **Agents** | `agents/` | Subagent Markdown files |
| **Skills** | `skills/` | Skills with `<name>/SKILL.md` structure |
| **Hooks** | `hooks/hooks.json` | Hook configuration |
| **MCP servers** | `.mcp.json` | MCP server definitions |
| **LSP servers** | `.lsp.json` | Language server configurations |
| **Settings** | `settings.json` | Default configuration applied when the plugin is enabled |

---

## CLI Commands Reference

### plugin install

```bash
claude plugin install <plugin> [options]
```

**Arguments**:
- `<plugin>`: Plugin name or `plugin-name@marketplace-name` for a specific marketplace

**Options**:
| Option | Description | Default |
|--------|-------------|---------|
| `-s, --scope <scope>` | Installation scope: `user`, `project`, or `local` | `user` |
| `-h, --help` | Display help for command | |

**Examples**:
```bash
# Install to user scope (default)
claude plugin install formatter@my-marketplace

# Install to project scope (shared with team)
claude plugin install formatter@my-marketplace --scope project

# Install to local scope (gitignored)
claude plugin install formatter@my-marketplace --scope local
```

### plugin uninstall

```bash
claude plugin uninstall <plugin> [options]
```

**Aliases**: `remove`, `rm`

**Options**:
| Option | Description | Default |
|--------|-------------|---------|
| `-s, --scope <scope>` | Uninstall from scope: `user`, `project`, or `local` | `user` |

### plugin enable

```bash
claude plugin enable <plugin> [options]
```

### plugin disable

```bash
claude plugin disable <plugin> [options]
```

### plugin update

```bash
claude plugin update <plugin> [options]
```

---

## Troubleshooting

### Debugging Commands

Use `claude --debug` (or `/debug` within the TUI) to see plugin loading details:
- Which plugins are being loaded
- Any errors in plugin manifests
- Command, agent, and hook registration
- MCP server initialization

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Plugin not loading | Invalid `plugin.json` | Validate JSON syntax with `claude plugin validate` or `/plugin validate` |
| Commands not appearing | Wrong directory structure | Ensure `commands/` at root, not in `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |
| LSP `Executable not found in $PATH` | Language server not installed | Install the binary |

### Example Error Messages

**Manifest validation errors**:
- `Invalid JSON syntax: Unexpected token } in JSON at position 142`: check for missing commas
- `Plugin has an invalid manifest file... name: Required`: a required field is missing

**Plugin loading errors**:
- `Warning: No commands found in plugin my-plugin...`: command path exists but contains no valid files
- `Plugin directory not found at path...`: the `source` path in marketplace.json is wrong

### Hook Troubleshooting

**Hook script not executing**:
1. Check the script is executable: `chmod +x ./scripts/your-script.sh`
2. Verify the shebang line: First line should be `#!/bin/bash` or `#!/usr/bin/env bash`
3. Check the path uses `${CLAUDE_PLUGIN_ROOT}`
4. Test the script manually

**Hook not triggering on expected events**:
1. Verify the event name is correct (case-sensitive): `PostToolUse`, not `postToolUse`
2. Check the matcher pattern matches your tools: `"matcher": "Write|Edit"`
3. Confirm the hook type is valid: `command`, `prompt`, or `agent`

### MCP Server Troubleshooting

**Server not starting**:
1. Check the command exists and is executable
2. Verify all paths use `${CLAUDE_PLUGIN_ROOT}` variable
3. Check the MCP server logs: `claude --debug` shows initialization errors
4. Test the server manually outside of Claude Code

### Directory Structure Mistakes

**Symptoms**: Plugin loads but components (commands, agents, hooks) are missing.

**Correct structure**: Components must be at the plugin root, not inside `.claude-plugin/`.

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      ← Only manifest here
├── commands/            ← At root level
├── agents/              ← At root level
└── hooks/               ← At root level
```

---

## Version Management

Follow semantic versioning for plugin releases:

**Version format**: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backward-compatible additions)
- **PATCH**: Bug fixes (backward-compatible fixes)

**Best practices**:
- Start at `1.0.0` for your first stable release
- Update the version in `plugin.json` before distributing changes
- Document changes in a `CHANGELOG.md` file
- Use pre-release versions like `2.0.0-beta.1` for testing
