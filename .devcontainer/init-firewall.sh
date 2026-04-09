#!/bin/bash
set -euo pipefail

# Prevent code exfiltration: whitelist trusted domains, block all other egress.

SETTINGS_DIR="/workspace/.claude"

# Base domains always needed
TRUSTED_DOMAINS=(
    pypi.org files.pythonhosted.org
    github.com api.github.com
    astral.sh
    claude.ai api.anthropic.com
    sentry.io statsig.anthropic.com statsig.com
    marketplace.visualstudio.com vscode.blob.core.windows.net update.code.visualstudio.com
)

# Extract domains from WebFetch(domain:...) patterns in settings.json
for f in "$SETTINGS_DIR/settings.json" "$SETTINGS_DIR/settings.local.json"; do
    [ -f "$f" ] || continue
    while read -r domain; do
        [ -z "$domain" ] && continue
        [[ "$domain" == \** ]] && continue  # skip wildcards
        TRUSTED_DOMAINS+=("$domain")
    done < <(jq -r '
        [(.permissions.allow // []), (.permissions.ask // [])] | add
        | .[] | select(startswith("WebFetch(domain:"))
        | sub("^WebFetch\\(domain:"; "") | sub("\\)$"; "")
    ' "$f" 2>/dev/null)
done

# Resolve and whitelist
ipset create trusted hash:net 2>/dev/null || true
for domain in "${TRUSTED_DOMAINS[@]}"; do
    for ip in $(dig +short A "$domain" 2>/dev/null); do
        [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ipset add trusted "$ip" 2>/dev/null || true
    done
done

# Allow: localhost, DNS, host network, established, trusted domains
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -d "$(ip route | grep default | awk '{print $3}' | sed 's/\.[0-9]*$/.0\/24/')" -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m set --match-set trusted dst -j ACCEPT
iptables -A OUTPUT -j REJECT
iptables -P OUTPUT DROP

# Block IPv6 egress
ip6tables -P OUTPUT DROP 2>/dev/null || true
ip6tables -A OUTPUT -o lo -j ACCEPT 2>/dev/null || true
