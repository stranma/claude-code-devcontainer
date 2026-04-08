# claude-code-devcontainer [DEPRECATED]

> **This repo is deprecated.** Use [trailofbits/claude-code-devcontainer](https://github.com/trailofbits/claude-code-devcontainer) instead -- it provides a more mature solution with OAuth token forwarding, `devc` CLI for lifecycle management, and better security isolation.

## Migration

1. Install the Trail of Bits devcontainer:
   ```bash
   git clone https://github.com/trailofbits/claude-code-devcontainer
   cd claude-code-devcontainer
   bash install.sh self-install
   ```

2. Set up auth on your host:
   ```bash
   claude setup-token
   ```

3. Use `devc` to manage containers:
   ```bash
   devc .              # Install template + start
   devc up             # Start
   devc shell          # Open shell
   devc rebuild        # Clean rebuild
   devc destroy        # Remove all resources
   ```

## Why Trail of Bits?

| Feature | This repo | Trail of Bits |
|---------|-----------|---------------|
| Auth handling | Manual login each time | OAuth token forwarding |
| CLI tool | None | `devc` (rebuild, sync, mount, upgrade) |
| Config persistence | Named volume only | Volume + auto-seeded settings |
| Firewall | Strict iptables whitelist | Optional, manual iptables |
| Base image | Python 3.12 Bookworm | Ubuntu 24.04 + Python 3.13 |
| Dev tools | git-delta, fzf, gh | ripgrep, fd, tmux, fzf, delta, ast-grep |

If you need the strict egress firewall from this repo, you can add `init-firewall.sh` and `firewall-domains.conf` to a Trail of Bits setup as a `postStartCommand`.
