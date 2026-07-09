# C++23 <print> needs GCC 14+; g++-14 is preinstalled on the CI runner. If it
# isn't present (e.g. an older dev machine) skip (exit 42) rather than fail on a
# plain g++ that can't compile the source.
CXX=$(command -v g++-14)
if [ -z "$CXX" ]; then
    echo "g++-14 not found — needs GCC 14+ for C++23 <print>" >&2
    exit 42
fi
"$CXX" lambda-core.cpp -std=c++23 -o lambda-core.test || exit 1
./lambda-core.test
status=$?
rm -f lambda-core.test
exit $status
