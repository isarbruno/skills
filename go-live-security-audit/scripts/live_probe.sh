#!/usr/bin/env bash
# Harmless black-box probe of a web app we operate. Only GET, HEAD and OPTIONS (plus one TRACE),
# one request per second, no form submissions. Prints cookie names, never cookie values.
# Usage: live_probe.sh https://app.example.com [/protected/path ...]
set -uo pipefail

BASE="${1:?usage: live_probe.sh <base-url> [protected paths...]}"; shift
BASE="${BASE%/}"
HOST="${BASE#*://}"; HOST="${HOST%%/*}"
UA="go-live-security-audit"

req() { sleep 1; curl -sS -A "$UA" --max-time 15 "$@" 2>/dev/null; }

echo "== Target $BASE"

echo "== TLS"
echo | openssl s_client -connect "$HOST:443" -servername "$HOST" 2>/dev/null \
  | openssl x509 -noout -subject -issuer -enddate 2>/dev/null || echo "REVIEW: no certificate read"
# SECLEVEL=0 so a modern local OpenSSL still offers the old protocols; a refusal then comes from the server.
for v in tls1 tls1_1; do
  if echo | openssl s_client -connect "$HOST:443" -servername "$HOST" -"$v" -cipher 'DEFAULT:@SECLEVEL=0' >/dev/null 2>&1; then
    echo "WEAK: $v accepted"
  else
    echo "ok: $v refused"
  fi
done

echo "== HTTP to HTTPS"
req -o /dev/null -w '%{http_code} -> %{redirect_url}\n' "http://$HOST/"

echo "== Security headers on /"
H=$(req -D - -o /dev/null "$BASE/" | tr -d '\r')
for h in strict-transport-security content-security-policy x-frame-options x-content-type-options referrer-policy permissions-policy; do
  line=$(printf '%s\n' "$H" | grep -i "^$h:")
  if [ -n "$line" ]; then echo "ok: $line"; else echo "MISSING: $h"; fi
done
printf '%s\n' "$H" | grep -iE '^(server|x-powered-by|via|x-aspnet-version|x-nextjs-[a-z-]+):' | sed 's/^/LEAK?: /'

echo "== Cookie flags (names only)"
for p in / "$@"; do
  req -D - -o /dev/null "$BASE$p" | tr -d '\r' | grep -i '^set-cookie:' | while read -r c; do
    name=$(printf '%s' "$c" | sed -E 's/^[Ss]et-[Cc]ookie:[[:space:]]*([^=]+)=.*/\1/')
    flags=""
    printf '%s' "$c" | grep -qi '; *secure' || flags="$flags no-Secure"
    printf '%s' "$c" | grep -qi '; *httponly' || flags="$flags no-HttpOnly"
    printf '%s' "$c" | grep -qi '; *samesite' || flags="$flags no-SameSite"
    if [ -n "$flags" ]; then echo "REVIEW: $p cookie $name:$flags"; else echo "ok: $p cookie $name"; fi
  done
done

echo "== Files that must not be public (expect 404, 403 or a redirect to login)"
for p in /.env /.env.local /.env.production /.git/HEAD /.git/config /.DS_Store /docker-compose.yml \
         /Dockerfile /package.json /package-lock.json /prisma/schema.prisma /server.js /.next/BUILD_ID \
         /backup.zip /db.sqlite /data/ /api/health /debug /phpinfo.php /server-status /robots.txt /sitemap.xml; do
  out=$(req -o /dev/null -w '%{http_code} %{size_download}' "$BASE$p")
  code=${out%% *}
  case "$code" in
    200) echo "REVIEW: 200 $p (${out#* } bytes)";;
    *)   echo "ok: $code $p";;
  esac
done

echo "== Source maps"
page=$(req -L "$BASE/")
js=$(printf '%s' "$page" | grep -oE '(src|href)="[^"]+\.js"' | head -3 | sed -E 's/^(src|href)="//; s/"$//')
if [ -z "$js" ]; then echo "REVIEW: no script found on /"; fi
for j in $js; do
  case "$j" in http*) url="$j";; /*) url="$BASE$j";; *) url="$BASE/$j";; esac
  code=$(req -o /dev/null -w '%{http_code}' "$url.map")
  if [ "$code" = "200" ]; then echo "LEAK?: source map public $j.map"; else echo "ok: $code $j.map"; fi
done

echo "== Methods and CORS"
req -X OPTIONS -D - -o /dev/null "$BASE/" | tr -d '\r' | grep -iE '^(allow|access-control-allow-[a-z]+):' | sed 's/^/REVIEW: /'
req -X TRACE -o /dev/null -w 'TRACE %{http_code}\n' "$BASE/"
cors=$(req -D - -o /dev/null -H 'Origin: https://evil.example' "$BASE/" | tr -d '\r' | grep -i '^access-control-allow')
if [ -n "$cors" ]; then printf '%s\n' "$cors" | sed 's/^/REVIEW: /'; else echo "ok: no CORS headers for a foreign origin"; fi

if [ "$#" -gt 0 ]; then
  echo "== Protected paths without a session (expect 3xx to login, 401 or 403)"
  for p in "$@"; do
    out=$(req -o /dev/null -w '%{http_code} %{redirect_url}' "$BASE$p")
    case "${out%% *}" in
      30[1278]|401|403) echo "ok: $p $out";;
      *) echo "REVIEW: $p $out";;
    esac
    # Next.js CVE-2025-29927: middleware skipped when this header is present.
    code=$(req -o /dev/null -w '%{http_code}' -H 'x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware' "$BASE$p")
    if [ "$code" = "200" ]; then echo "REVIEW: $p answers 200 with x-middleware-subrequest"; fi
  done
fi

echo "== Error page"
body=$(req -L "$BASE/does-not-exist-$RANDOM")
leaks=$(printf '%s' "$body" | grep -oiE '(stack ?trace|traceback|exception|at [A-Za-z_.]+ \(/|/app/src|/home/[a-z]+|/usr/src/app|prisma[A-Za-z.]*error|sqlite_|syntax error at)' | sort -u)
if [ -n "$leaks" ]; then printf '%s\n' "$leaks" | sed 's/^/LEAK?: /'; else echo "ok: no stack or path markers"; fi

echo "== Common ports reachable from here"
IP=$(dig +short "$HOST" | grep -E '^[0-9.]+$' | tail -1)
if [ -z "$IP" ]; then echo "REVIEW: no A record for $HOST"; exit 0; fi
if nc -h 2>&1 | grep -q -- ' -G'; then NC="nc -z -G 2 -w 2"; else NC="nc -z -w 2"; fi
for port in 21 22 25 80 443 2019 3000 3001 3306 5432 5678 6379 8000 8080 8443 9000 9090 27017; do
  if $NC "$IP" "$port" >/dev/null 2>&1; then echo "open: $IP:$port"; fi
done
echo "== Done"
