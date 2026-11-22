#!/usr/bin/env bash
# Write the JessStack section into <config dir>/CLAUDE.md.
# The section sits between the lines <!-- jessstack:begin --> and <!-- jessstack:end -->.
# Claude Code strips block-level HTML comments when it loads CLAUDE.md, so the markers
# cost no context. <config dir> is $CLAUDE_CONFIG_DIR, or ~/.claude when unset.
# Before it changes CLAUDE.md, it copies the old file to CLAUDE.md.bak-<timestamp>[-<n>].
# Dependencies: awk, cat, cmp, grep, mkdir, mktemp, date.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: write-claude-section.sh <section-file>

Writes the text of <section-file> into <config dir>/CLAUDE.md between the
lines "<!-- jessstack:begin -->" and "<!-- jessstack:end -->". If the markers
exist, the script replaces the text between them. If not, it adds the
section to the end of the file. It also removes the lines
"Read @JESSSTACK_GLOSSARY.md" and "Read @JESSSTACK_CLAUDE_RULES.md".
<config dir> is $CLAUDE_CONFIG_DIR, or ~/.claude when it is not set.

  -h, --help  Show this help.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  '') usage >&2; exit 2 ;;
esac
if [ $# -ne 1 ]; then
  usage >&2
  exit 2
fi

section_file=$1
config_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
target_file="$config_dir/CLAUDE.md"
timestamp=$(date +%Y%m%d%H%M%S)
begin_pattern='^<!-- jessstack:begin -->'$'\r''?$'
end_pattern='^<!-- jessstack:end -->'$'\r''?$'

if [ ! -f "$section_file" ]; then
  echo "error: $section_file not found." >&2
  exit 1
fi
if grep -qE "$begin_pattern|$end_pattern" "$section_file"; then
  echo "error: $section_file holds a jessstack marker line. Remove it; this script adds the markers." >&2
  exit 1
fi

mkdir -p "$config_dir"
source_file=/dev/null
mode=append
if [ -f "$target_file" ]; then
  source_file=$target_file
  begin_count=$(grep -cE "$begin_pattern" "$target_file" || true)
  end_count=$(grep -cE "$end_pattern" "$target_file" || true)
  if [ "$begin_count" -eq 1 ] && [ "$end_count" -eq 1 ]; then
    begin_line=$(grep -nE "$begin_pattern" "$target_file" | cut -d: -f1)
    end_line=$(grep -nE "$end_pattern" "$target_file" | cut -d: -f1)
    if [ "$begin_line" -gt "$end_line" ]; then
      echo "error: $target_file has the end marker before the begin marker. No change made." >&2
      exit 1
    fi
    mode=replace
  elif [ "$begin_count" -ne 0 ] || [ "$end_count" -ne 0 ]; then
    echo "error: $target_file has $begin_count begin and $end_count end markers. It must have one of each, or none. No change made." >&2
    exit 1
  fi
fi

temp_file=$(mktemp "$config_dir/CLAUDE.md.tmp-XXXXXX")
trap 'rm -f "$temp_file"' EXIT

awk -v section_file="$section_file" -v mode="$mode" \
    -v begin_pattern="$begin_pattern" -v end_pattern="$end_pattern" '
function emit_block(   line) {
  print "<!-- jessstack:begin -->"
  print "<!-- Run /jessstack:setup-jessstack to change this section. It replaces all text between these markers. -->"
  while ((getline line < section_file) > 0) print line
  close(section_file)
  print "<!-- jessstack:end -->"
}
$0 ~ begin_pattern { emit_block(); skipping = 1; next }
skipping && $0 ~ end_pattern { skipping = 0; next }
skipping { next }
/^Read @JESSSTACK_(GLOSSARY|CLAUDE_RULES)\.md\r?$/ { next }
{ print; last = $0 }
END {
  if (mode == "append") {
    if (last !~ /^\r?$/) print ""
    emit_block()
  }
}
' "$source_file" > "$temp_file"

if [ -f "$target_file" ] && cmp -s "$temp_file" "$target_file"; then
  echo "CLAUDE.md: $target_file is up to date."
  exit 0
fi

if [ -f "$target_file" ]; then
  backup_file="$target_file.bak-$timestamp"
  suffix=1
  while [ -e "$backup_file" ]; do
    backup_file="$target_file.bak-$timestamp-$suffix"
    suffix=$((suffix + 1))
  done
  cp -p "$target_file" "$backup_file"
  echo "CLAUDE.md: copied the old file to $backup_file."
fi
# Write through the path so that a symlinked CLAUDE.md keeps its link and mode.
cat "$temp_file" > "$target_file"
if [ "$mode" = replace ]; then
  echo "CLAUDE.md: replaced the JessStack section in $target_file."
else
  echo "CLAUDE.md: added the JessStack section to the end of $target_file."
fi
