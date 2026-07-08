gcc lambda-core.c -std=c89 -pedantic -o lambda-core.test || exit 1
./lambda-core.test
status=$?
rm -f lambda-core.test
exit $status
