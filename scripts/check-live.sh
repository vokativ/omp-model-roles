#!/usr/bin/env bash
# Diff model-roles.yml against the live omp config. Needs ruby + jq; run from the repo root.
# Prints OK/DIFF per key and exits non-zero on any DIFF (also fails if model-roles.yml does not parse).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
status=0
for k in modelRoles retry.fallbackChains retry.usageAwareFallback retry.usageReservePolicy \
         task.agentModelOverrides cycleOrder extendedContext defaultThinkingLevel update.auto \
         compaction.modelThresholds; do
  want=$(ruby -ryaml -rjson -e 'v = YAML.load_file("model-roles.yml").dig(*ARGV[0].split(".")); puts JSON.generate(v)' "$k") || exit 2
  have=$(omp config get "$k" --json | jq -c .value)
  if diff <(jq -S . <<<"$want") <(jq -S . <<<"$have") >/dev/null; then
    echo "OK   $k"
  else
    echo "DIFF $k"; echo "  file: $want"; echo "  live: $have"; status=1
  fi
done
exit $status
