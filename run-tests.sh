#!/bin/sh
# Runs every language folder that has a test.sh and compares its stdout against
# that folder's expected-output.txt. Result categories:
#
#   PASS     ran, exit 0, output matched the baseline.
#   FAIL     ran but exited nonzero or output did not match. A real problem.
#            This is the ONLY category that makes the script exit nonzero.
#   SKIP     the language's toolchain is not available in this environment: the
#            command was not found (exit 127) or the test.sh opted out (exit 42).
#            Skipping is normal locally for CI-only toolchains. On CI (the CI env
#            var is set) a skip is upgraded to a FAIL, because the runner is
#            supposed to have every toolchain installed — a missing one there is
#            a broken install, not an expected absence.
#   PENDING  the folder has a test.sh but no expected-output.txt baseline yet.
#            Its output is printed so it can be captured; never a failure.
#
# Folders without a test.sh are skipped entirely (not yet backfilled).
set -u

root=$(cd "$(dirname "$0")" && pwd)
on_ci=${CI:-}

pass=0
fail=0
skip=0
pending=0
failed_names=""

for script in "$root"/languages/*/*/test.sh; do
    [ -e "$script" ] || continue
    dir=$(dirname "$script")
    name=${dir#"$root"/languages/}

    if [ ! -f "$dir/expected-output.txt" ]; then
        actual=$( (cd "$dir" && sh test.sh 2>/dev/null) )
        echo "PENDING  $name  (no expected-output.txt baseline yet)"
        echo "--- captured output (paste into expected-output.txt once verified) ---"
        echo "$actual"
        echo "---"
        pending=$((pending + 1))
        continue
    fi

    actual=$( (cd "$dir" && sh test.sh 2>/dev/null) )
    status=$?
    expected=$(cat "$dir/expected-output.txt")

    if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ]; then
        echo "PASS     $name"
        pass=$((pass + 1))
    elif [ "$status" -eq 42 ] || [ "$status" -eq 127 ]; then
        if [ -n "$on_ci" ]; then
            echo "FAIL     $name  (toolchain missing on CI — exit $status)"
            fail=$((fail + 1))
            failed_names="$failed_names $name"
        else
            echo "SKIP     $name  (toolchain not installed here)"
            skip=$((skip + 1))
        fi
    else
        echo "FAIL     $name  (exit $status)"
        echo "--- expected ---"
        echo "$expected"
        echo "--- actual ---"
        echo "$actual"
        echo "---"
        fail=$((fail + 1))
        failed_names="$failed_names $name"
    fi
done

echo
echo "Summary: $pass passed, $fail failed, $skip skipped, $pending pending"
if [ -n "$failed_names" ]; then
    echo "FAILED:$failed_names"
fi

[ "$fail" -eq 0 ] || exit 1
exit 0
