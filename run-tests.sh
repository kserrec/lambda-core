#!/bin/sh
# Runs every language folder that has a test.sh and compares its stdout
# against that folder's expected-output.txt. Exits nonzero if any differ.
# Folders without a test.sh are skipped (not yet backfilled).
set -u

root=$(cd "$(dirname "$0")" && pwd)
fail=0
ran=0

for script in "$root"/languages/*/*/test.sh; do
    [ -e "$script" ] || continue
    dir=$(dirname "$script")
    name=${dir#"$root"/languages/}
    ran=$((ran + 1))

    actual=$( (cd "$dir" && sh test.sh 2>/dev/null) )
    status=$?
    expected=$(cat "$dir/expected-output.txt")

    if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ]; then
        echo "PASS  $name"
    else
        echo "FAIL  $name (exit $status)"
        echo "--- expected ---"
        echo "$expected"
        echo "--- actual ---"
        echo "$actual"
        echo "---"
        fail=1
    fi
done

echo "$ran folder(s) tested"
exit $fail
