#!/usr/bin/env bash
# Install statusline.sh as the Claude Code status line.
# Copies statusline.sh to <config dir>/statusline.sh and sets the statusLine entry in
# <config dir>/settings.json. <config dir> is $CLAUDE_CONFIG_DIR, or ~/.claude when unset.
# Before it replaces a file, it copies the old file to <file>.bak-<timestamp>.
# Dependencies: cp, cmp, mkdir, dirname, date. python3 to edit settings.json.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-statusline.sh [--force]

Copies statusline.sh to <config dir>/statusline.sh and sets the statusLine
entry in <config dir>/settings.json. <config dir> is $CLAUDE_CONFIG_DIR, or
~/.claude when it is not set.

  --force     Replace a statusLine entry that runs a different command.
  -h, --help  Show this help.
EOF
}

force=0
case "${1:-}" in
  '') ;;
  --force) force=1 ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac
if [ $# -gt 1 ]; then
  usage >&2
  exit 2
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source_file="$script_dir/statusline.sh"
config_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
target_file="$config_dir/statusline.sh"
settings_file="$config_dir/settings.json"
timestamp=$(date +%Y%m%d%H%M%S)

# Claude Code runs the command through a shell, so "~" expands there.
if [ "$config_dir" = "$HOME/.claude" ]; then
  statusline_command='bash ~/.claude/statusline.sh'
else
  statusline_command="bash \"$target_file\""
fi

if [ ! -f "$source_file" ]; then
  echo "error: $source_file not found." >&2
  exit 1
fi

# ---- Copy the script --------------------------------------------------------
mkdir -p "$config_dir"
if [ -f "$target_file" ] && cmp -s "$source_file" "$target_file"; then
  echo "statusline.sh: $target_file is up to date."
else
  if [ -f "$target_file" ]; then
    cp -p "$target_file" "$target_file.bak-$timestamp"
    echo "statusline.sh: copied the old file to $target_file.bak-$timestamp."
  fi
  cp "$source_file" "$target_file"
  echo "statusline.sh: installed $target_file."
fi

# ---- Set the statusLine entry -----------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "settings.json: python3 not found. Add this entry to $settings_file:" >&2
  printf '  "statusLine": {\n    "type": "command",\n    "command": "%s",\n    "refreshInterval": 1\n  }\n' \
    "${statusline_command//\"/\\\"}" >&2
  exit 1
fi

# Exit status: 0 when the entry is set or up to date, 1 when the script cannot set it.
python3 - "$settings_file" "$statusline_command" "$force" "$timestamp" <<'PY'
import json, os, shutil, sys

path, command, force, timestamp = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4]

settings = {}
if os.path.exists(path):
    try:
        with open(path, encoding="utf-8") as f:
            settings = json.load(f)
    except (OSError, ValueError) as e:
        sys.exit(f"settings.json: cannot read {path}: {e}. No change made.")
    if not isinstance(settings, dict):
        sys.exit(f"settings.json: {path} does not hold a JSON object. No change made.")

current = settings.get("statusLine")
same_command = isinstance(current, dict) and current.get("command") == command
if current is not None and not same_command and not force:
    other = current.get("command") if isinstance(current, dict) else current
    sys.exit(f"settings.json: statusLine runs a different command ({other}). "
             "No change made. Run again with --force to replace it.")

# For the same command, keep the other fields, such as padding or a refreshInterval
# that the user set. The refreshInterval of 1 second lets the Honcho glyph animate.
wanted = dict(current) if same_command else {}
wanted["type"] = "command"
wanted["command"] = command
wanted.setdefault("refreshInterval", 1)
if wanted == current:
    print("settings.json: statusLine is up to date.")
    sys.exit(0)

settings["statusLine"] = wanted
temp_path = f"{path}.tmp-{timestamp}"
with open(temp_path, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
if os.path.exists(path):
    shutil.copymode(path, temp_path)
    shutil.copy2(path, f"{path}.bak-{timestamp}")
    print(f"settings.json: copied the old file to {path}.bak-{timestamp}.")
os.replace(temp_path, path)
print(f"settings.json: set statusLine in {path}.")
PY

if [ ! -f "$HOME/.honcho/honcho-statusline.sh" ]; then
  echo "Honcho segment: ~/.honcho/honcho-statusline.sh not found. To show the segment," \
    "install the Honcho plugin and run /honcho:setup."
fi
