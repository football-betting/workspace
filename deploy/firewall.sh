#!/usr/bin/env bash
# Lock the origin down with ufw: only SSH from anywhere, and HTTP/HTTPS only
# from Cloudflare's published ranges — so the origin is reachable only through
# Cloudflare (no direct-IP access that would bypass the WAF / rate limiting).
# Loopback is allowed by default, so nginx -> 127.0.0.1:3000/:8090 keeps working.
#
# Safe to re-run. SSH is allowed BEFORE enabling so you can't lock yourself out.
set -euo pipefail

CF4=(
  173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22
  141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20
  197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13
  104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
)
CF6=(
  2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32
  2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
)

ufw allow OpenSSH                    # keep SSH reachable (do this first!)
for r in "${CF4[@]}" "${CF6[@]}"; do
  ufw allow from "$r" to any port 80,443 proto tcp
done
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
ufw status verbose
