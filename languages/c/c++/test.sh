CXX=$(command -v g++-14 || command -v g++)
"$CXX" lambda-core.cpp -std=c++23 -o lambda-core.test || exit 1
./lambda-core.test
status=$?
rm -f lambda-core.test
exit $status
