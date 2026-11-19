#!/usr/bin/env bash
# Lists added lines that need review: suppressions, timers and sleeps,
# discarded errors, type escapes, deferred-work markers, and comments.
#
# Usage: scan-added-lines.sh [base-ref]
#   No base-ref: scans uncommitted changes (staged and unstaged) and untracked files.
#   base-ref:    scans all changes since the merge base of base-ref and HEAD,
#                plus uncommitted changes and untracked files.
#
# Output: one line per finding, "path:line: category: text".
# Exit status: 0 = no findings, 1 = findings, 2 = usage error.

set -euo pipefail

if [[ $# -gt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "scan-added-lines: run this script inside a git repository." >&2
  exit 2
fi
cd "$(git rev-parse --show-toplevel)"

if [[ $# -eq 1 ]]; then
  if ! base=$(git merge-base "$1" HEAD 2>/dev/null); then
    echo "scan-added-lines: '$1' is not a valid ref. Give a branch, tag, or commit." >&2
    exit 2
  fi
elif git rev-parse --verify --quiet HEAD >/dev/null; then
  base=HEAD
else
  base=$(git hash-object -t tree /dev/null)
fi

skip_re='(^|/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|Cargo\.lock|poetry\.lock|uv\.lock|packages\.lock\.json)$|\.(lock|min\.js|snap|svg|md|txt|json)$'

emit_added_lines() {
  git diff --no-color --no-ext-diff --unified=0 "$base" -- . |
    awk '
      /^\+\+\+ / { file = substr($0, 5); sub(/^b\//, "", file); next }
      /^@@ / {
        split($3, parts, ",")
        line = substr(parts[1], 2) + 0
        next
      }
      /^\+/ { print file "\t" line "\t" substr($0, 2); line++; next }
    '
  git ls-files --others --exclude-standard -z |
    while IFS= read -r -d '' path; do
      [[ -f "$path" ]] || continue
      grep -Iq . "$path" 2>/dev/null || continue
      awk -v file="$path" '{ print file "\t" NR "\t" $0 }' "$path"
    done
}

emit_added_lines |
  SKIP_RE="$skip_re" awk -F'\t' '
    function report(category) {
      text = $3
      sub(/^[ \t]+/, "", text)
      print $1 ":" $2 ": " category ": " text
      found = 1
    }
    function hash_comment_file(path) {
      return path ~ /\.(py|sh|bash|zsh|rb|pl|r|R|toml|ya?ml|ps1|cfg|ini|conf)$/ ||
             path ~ /(^|\/)(Makefile|Dockerfile|justfile|\.gitignore|\.editorconfig)$/
    }
    function slash_comment_file(path) {
      return path ~ /\.(js|jsx|mjs|cjs|ts|tsx|mts|cts|svelte|vue|rs|cs|java|kt|kts|go|swift|c|h|cc|cpp|hpp|scss|less|css|dart|php|scala|groovy|zig)$/
    }
    BEGIN { skip_re = ENVIRON["SKIP_RE"] }
    $1 ~ skip_re { next }
    {
      code = $3
      if (code ~ /eslint-disable|biome-ignore|@ts-ignore|@ts-expect-error|@ts-nocheck|svelte-ignore|prettier-ignore|#!?\[allow\(|noqa|type: *ignore|pylint: *disable|#pragma +warning +disable|SuppressMessage|nolint|rubocop:disable|istanbul +ignore|c8 +ignore/) {
        report("suppression"); next
      }
      if (code ~ /(^|[^A-Za-z0-9_])(setTimeout|setInterval|requestAnimationFrame|requestIdleCallback|queueMicrotask)[ \t]*[(]/ ||
          code ~ /(Thread\.Sleep|Task\.Delay|thread::sleep|time::sleep|time\.[sS]leep|asyncio\.sleep|Thread\.sleep)[ \t]*[(]/) {
        report("timer-or-sleep"); next
      }
      if (code ~ /catch[ \t]*([(][^)]*[)])?[ \t]*[{][ \t]*[}]/ ||
          code ~ /except([ \t][^:]*)?:[ \t]*(pass|\.\.\.)[ \t]*$/ ||
          code ~ /\.catch[(][ \t]*[(][ \t]*[)][ \t]*=>[ \t]*[{]?[ \t]*[}]?[ \t]*[)]/ ||
          code ~ /let[ \t]+_[ \t]*=/) {
        report("discarded-error"); next
      }
      if (code ~ /as[ \t]+any([^A-Za-z0-9_]|$)|as[ \t]+unknown[ \t]+as|:[ \t]*any([^A-Za-z0-9_]|$)|<any>/) {
        report("type-escape"); next
      }
      if (code ~ /(^|[^A-Za-z0-9_])(TODO|FIXME|HACK|XXX)([^A-Za-z0-9_]|$)/) {
        report("deferred-work"); next
      }
      trimmed = code
      sub(/^[ \t]+/, "", trimmed)
      if (slash_comment_file($1)) {
        if (trimmed ~ /^(\/\/\/|\/\/!|\/\*\*)/) { report("doc-comment"); next }
        if (trimmed ~ /^(\/\/|\/\*|\*[ \/]|\*$)/ || code ~ /[;{})][ \t]*\/\/[ \t]/) { report("comment"); next }
      }
      if (hash_comment_file($1)) {
        if (trimmed ~ /^#/ && trimmed !~ /^#!/ && trimmed !~ /^#\[/) { report("comment"); next }
      }
      if ($1 ~ /\.(html|svelte|vue|xml|csproj|props|targets|razor)$/ && trimmed ~ /^<!--|^@\*/) {
        report("comment"); next
      }
    }
    END { exit found ? 1 : 0 }
  '
