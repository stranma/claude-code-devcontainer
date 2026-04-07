# claude-code-devcontainer

Secure Python devcontainer for Claude Code with network egress firewall.

## What's Included

- **Python 3.12** (Debian Bookworm) with `uv` package manager
- **Claude Code CLI** (native installer)
- **Egress firewall** (iptables whitelist: PyPI, GitHub, Anthropic, VS Code, Astral)
- **VS Code extensions**: Python, Pylance, Ruff, Debugpy, GitLens, Claude Code
- **Shell**: zsh with Powerlevel10k, fzf, git-delta
- **Non-root user** (`vscode`, UID 1000) with restricted sudo (firewall only)

## Usage

### Option 1: Copy into your project

```bash
cp -r .devcontainer/ /path/to/your/project/.devcontainer/
cp .gitattributes /path/to/your/project/.gitattributes
```

### Option 2: Git submodule

```bash
cd /path/to/your/project
git submodule add <repo-url> .devcontainer-upstream
# Then symlink or copy what you need
```

## Configuration

### Python version

Edit `.devcontainer/Dockerfile` line 1:

```dockerfile
FROM python:3.12-bookworm  # Change to 3.11, 3.13, etc.
```

### Firewall domains

Add extra domains to `.devcontainer/firewall-domains.conf`:

```
registry.npmjs.org
dl.google.com
```

Changes take effect on container restart.

### Inbound traffic

By default, inbound traffic is permissive (Docker handles isolation). For strict inbound filtering:

```bash
# Set in your shell or .env before opening the devcontainer
export FIREWALL_ALLOW_INBOUND=false
```

## Architecture

```
.devcontainer/
  Dockerfile              Python base image, tools, Claude Code CLI
  devcontainer.json        VS Code integration, mounts, env vars
  init-firewall.sh         iptables egress whitelist
  firewall-domains.conf    Extra domains to whitelist (user-editable)
.gitattributes             LF line endings for container files
```

The firewall runs at container start (`postStartCommand`). It:
1. Fetches GitHub IP ranges from the API
2. Resolves built-in domains (PyPI, Anthropic, VS Code, etc.)
3. Resolves extra domains from `firewall-domains.conf`
4. Sets DROP policy on all other egress
5. Verifies by testing that `example.com` is blocked and `api.github.com` is reachable
