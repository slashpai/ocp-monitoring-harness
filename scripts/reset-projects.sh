#!/usr/bin/env bash
# Reset all projects/ submodules to the branch pinned in .gitmodules at remote HEAD.
# Adapted from https://github.com/observability-ui/harness/blob/main/scripts/reset-projects.sh
#
# Run after a task when implementation used projects/ submodules. Push branches to
# your fork before resetting — unpushed commits and uncommitted changes are discarded.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GITMODULES="$REPO_ROOT/.gitmodules"

if [[ ! -f "$GITMODULES" ]]; then
  echo "ERROR: .gitmodules not found at $GITMODULES" >&2
  exit 1
fi

TMPDIR_BASE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_BASE"' EXIT

normalize_url() {
  local url="$1"
  url="${url%.git}"
  url="${url%/}"
  url="${url#http://}"
  url="${url#https://}"
  echo "$url" | tr '[:upper:]' '[:lower:]'
}

find_remote_for_url() {
  local submodule_dir="$1"
  local canonical_url="$2"
  local normalized_canonical
  normalized_canonical="$(normalize_url "$canonical_url")"

  while IFS= read -r line; do
    local remote_name remote_url
    remote_name="$(echo "$line" | awk '{print $1}')"
    remote_url="$(echo "$line" | awk '{print $2}')"
    if [[ "$(normalize_url "$remote_url")" == "$normalized_canonical" ]]; then
      echo "$remote_name"
      return 0
    fi
  done < <(git -C "$submodule_dir" remote -v 2>/dev/null | grep '(fetch)')

  return 1
}

reset_submodule() {
  local name="$1"
  local path="$2"
  local branch="$3"
  local url="$4"
  local logfile="$5"
  local submodule_dir="$REPO_ROOT/$path"
  local display_name
  display_name="$(basename "$path")"

  (
    set +e
    echo "── $display_name ──────────────────────────────────"

    if [[ ! -d "$submodule_dir/.git" ]] && [[ ! -f "$submodule_dir/.git" ]]; then
      echo " initializing submodule..."
      if ! git -C "$REPO_ROOT" submodule update --init "$path" 2>&1; then
        echo " ERROR: failed to initialize submodule"
        exit 1
      fi
    fi

    local remote
    remote="$(find_remote_for_url "$submodule_dir" "$url")" || {
      echo " ERROR: no remote matches URL '$url'"
      exit 1
    }

    echo " branch: $branch remote: $remote"

    echo " fetching ${remote}/${branch}..."
    if ! git -C "$submodule_dir" fetch "$remote" "$branch" --quiet 2>&1; then
      echo " ERROR: fetch failed for ${remote}/${branch}"
      exit 1
    fi

    if ! git -C "$submodule_dir" checkout "$branch" --quiet 2>/dev/null; then
      if ! git -C "$submodule_dir" checkout -B "$branch" "${remote}/${branch}" --quiet 2>&1; then
        echo " ERROR: checkout failed for branch '$branch'"
        exit 1
      fi
    fi

    if ! git -C "$submodule_dir" reset --hard "${remote}/${branch}" --quiet 2>&1; then
      echo " ERROR: reset --hard failed for ${remote}/${branch}"
      exit 1
    fi

    git -C "$submodule_dir" clean -fd --quiet 2>&1 || true

    git -C "$submodule_dir" submodule update --init --recursive --quiet 2>&1 || true

    echo " reset to ${remote}/${branch} ✓"
  ) >"$logfile" 2>&1
}

echo "═══════════════════════════════════════════════════════════"
echo " Resetting all submodules to .gitmodules branches"
echo "═══════════════════════════════════════════════════════════"
echo ""

submodule_names=()
while IFS= read -r line; do
  key="${line%% *}"
  name="${key#submodule.}"
  name="${name%.path}"
  submodule_names+=("$name")
done < <(git config -f "$GITMODULES" --get-regexp 'submodule\..*\.path')

pids=()
logfiles=()
names=()
errors=()

for name in "${submodule_names[@]}"; do
  path="$(git config -f "$GITMODULES" "submodule.${name}.path" 2>/dev/null)" || true
  branch="$(git config -f "$GITMODULES" "submodule.${name}.branch" 2>/dev/null)" || true
  url="$(git config -f "$GITMODULES" "submodule.${name}.url" 2>/dev/null)" || true

  if [[ -z "$path" || -z "$branch" || -z "$url" ]]; then
    display="$name"
    [[ -n "$path" ]] && display="$(basename "$path")"
    echo "── $display ──────────────────────────────────"
    echo " SKIPPED: missing .gitmodules config (path=${path:-?} branch=${branch:-?} url=${url:-?})"
    echo ""
    errors+=("$display")
    continue
  fi

  logfile="$TMPDIR_BASE/$(basename "$path").log"

  reset_submodule "$name" "$path" "$branch" "$url" "$logfile" &
  pids+=($!)
  logfiles+=("$logfile")
  names+=("$(basename "$path")")
done

for i in "${!pids[@]}"; do
  if ! wait "${pids[$i]}"; then
    errors+=("${names[$i]}")
  fi
  if [[ -f "${logfiles[$i]}" ]]; then
    cat "${logfiles[$i]}"
    echo ""
  fi
done

echo "═══════════════════════════════════════════════════════════"
if [[ ${#errors[@]} -gt 0 ]]; then
  echo " Done with ${#errors[@]} error(s):"
  for err in "${errors[@]}"; do
    echo " - $err"
  done
  exit 1
else
  echo " All submodules reset successfully."
fi
echo "═══════════════════════════════════════════════════════════"
