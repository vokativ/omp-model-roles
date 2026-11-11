#!/usr/bin/env bash
# omp-recorded API-priced spend for one provider on this machine, per day (UTC), from session logs.
# usage: omp-spend.sh <provider> [since YYYY-MM-DD, default 1st of this month UTC]
# Columns: cost, calls, calls whose prompt (input + cacheRead) exceeded 150k, likely prefix-cache misses.
# Other machine: ssh <host> 'bash -s -- mistral' < scripts/omp-spend.sh
set -euo pipefail
provider="${1:?provider, e.g. mistral}"
since="${2:-$(date -u +%Y-%m-01)}"
find "${OMP_SESSIONS:-$HOME/.omp/agent/sessions}" -name '*.jsonl' -newermt "$since" -print0 |
  xargs -0 -r grep -h "\"provider\":\"$provider\"" |
  jq -r --arg p "$provider" --arg s "$since" '
    select(.type=="message" and .message.provider==$p and .timestamp>=$s and .message.usage != null)
    | .message.usage as $u
    | [.timestamp[0:10], ($u.cost.total // 0), (($u.input // 0)+($u.cacheRead // 0)),
       ((($u.input // 0)>30000) and (($u.cacheRead // 0)<($u.input // 0)))] | @tsv' |
  awk -F'\t' -v p="$provider" -v s="$since" '
    {d[$1]+=$2; n[$1]++; t+=$2; if($3>150000) big[$1]++; if($4=="true") miss[$1]++}
    END{for(k in d) printf "%s  $%8.2f  calls=%-5d prompt>150k=%-5d cache-miss=%d\n",k,d[k],n[k],big[k]+0,miss[k]+0 | "sort"
        close("sort"); printf "TOTAL %s since %s  $%.2f\n",p,s,t}'
