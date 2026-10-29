# Live surface and host

Both sections are read-only. Probes stay at one request per second.

## Live

Run first:

```bash
bash <skill-dir>/scripts/live_probe.sh https://app.example.com /admin /dashboard /api/private
```

It checks TLS, the HTTP redirect, security headers, cookie flags (names only), files that must not be public, source maps, HTTP methods, CORS, protected paths without a session, the Next.js middleware bypass header, error pages and which common ports answer. Lines starting with `MISSING`, `WEAK`, `LEAK?`, `REVIEW` or `open` are candidates for the gate, not findings.

Then by hand:

- **Enumeration:** compare the responses of each login or reset form for a known and an unknown account. Two requests at most. If the form sends mail, use only the user's own address and ask first.
- **Rate limits:** do not test by sending requests. Read the code and the proxy config instead.
- **Public footprint:** `curl -s "https://crt.sh/?q=<domain>&output=json"` lists the certificates anyone can see. Check that no forgotten staging or admin hosts point at live data.
- **DNS:** records pointing at hosts or services no longer in use can be taken over.
- **Mail:** SPF, DKIM and DMARC for the sender domain. `p=none` on DMARC lets anyone spoof it.

## Host

Over SSH, read-only. Typical commands (Debian or Ubuntu with Docker).

Crontabs, compose files, proxy configs and env dumps often hold secrets of other apps on the same host. Pipe every such read through a mask before it reaches the transcript:

```bash
MASK='s/((secret|token|key|password|passwd|auth)[^ :=]*["]?[[:space:]]*[:=][[:space:]]*["]?)[^" ]{4}[^" ]*/\1****/Ig'
crontab -l | grep -v '^#' | sed -E "$MASK"
```

On a shared host, also note the other apps' exposure without auditing them.

| Check | Command | Bad sign |
|---|---|---|
| Listening sockets | `ss -tlnp` | App, database or admin ports on `0.0.0.0` instead of `127.0.0.1` |
| Published container ports | `docker ps --format '{{.Names}} {{.Ports}}'` | `0.0.0.0:<port>->` for anything but the reverse proxy. Docker writes iptables rules ahead of ufw, so ufw does not protect these. |
| Firewall | `ufw status verbose; iptables -S \| head -40` | Inactive with exposed ports. Ask about the cloud provider firewall, it does not show on the host. |
| SSH | `sshd -T \| grep -E '^(passwordauthentication\|permitrootlogin\|kbdinteractiveauthentication\|pubkeyauthentication) '` | Password or keyboard-interactive auth on |
| Updates | `systemctl is-enabled unattended-upgrades; apt list --upgradable 2>/dev/null \| wc -l; ls /var/run/reboot-required` | Security updates not automatic, reboot pending for weeks |
| Container user | `docker inspect -f '{{.Name}} {{.Config.User}}' $(docker ps -q)` | Empty user means root in the container |
| Secrets in images | `docker history --no-trunc <image> \| grep -iE 'secret\|token\|key\|password'` | Secrets baked into layers or build args |
| Env files | `stat -c '%a %U %n' <app-dir>/.env*` | Not `600` |
| Build context | `.dockerignore` in the repo | `.env`, `data/` or `.git` not excluded |
| Shared host | `docker ps`, `docker network ls`, `docker network inspect <net>` | Unrelated apps on one network can reach each other's internal ports |
| Reverse proxy | the proxy config, e.g. `Caddyfile` or nginx sites | Unknown vhosts, admin API on a public interface (Caddy `:2019`), missing headers |
| Backups | masked crontab (above), backup dir, `stat` | Only on the same disk, world readable, never restore-tested |
| Users | `awk -F: '($2!~/^[!*]/ && $2!=""){print $1}' /etc/shadow` | Accounts with a password while SSH password auth is on |
| Logs | `docker logs --tail 200 <app>` | Tokens, magic links or personal data in logs |

Personal data on the host makes backups and access logs part of GDPR Art. 32. Note where they live and who can read them.
