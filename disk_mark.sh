#!/bin/bash

DEF_BLOCKS=1024
TESTFILE="testfile_$$.tmp"
DEF_TESTS="seq 8M 1M rand 4K"

read -p "Enter blocks count [${DEF_BLOCKS}]: " COUNT
read -p "Enter tests you want [${DEF_TESTS}](allowed \"seq, rand, 0-9+K,M,G\"): " TESTS
read -ep "Enter mount path to dev: " DEV_PATH

TESTS="$(echo $TESTS | grep -E '^((seq|rand) ([0-9]+[KMG] ?)+)+$')"

[ -z "${COUNT}" ] && COUNT=$DEF_BLOCKS
[ -z "${TESTS}" ] && TESTS=$DEF_TESTS

[ -z "${DEV_PATH}" ] && echo -e "Need right mount path!" && exit 0

[ "${DEV_PATH: -1}" = "/" ] && FULL_PATH=${DEV_PATH}${TESTFILE} || FULL_PATH=${DEV_PATH}/${TESTFILE}

echo -e "\nPath with test file: ${FULL_PATH}\n"

SEQ_WRITE_CMD="dd if=/dev/zero of=${FULL_PATH} bs="
RAND_WRITE_CMD="dd if=/dev/urandom of=${FULL_PATH} bs="
READ_CMD="dd if=${FULL_PATH} of=/dev/null bs="
PIPE_CMD=" count=${COUNT} conv=fdatasync 2>&1 | grep -E 'copied|bytes' | grep -o '[0-9.,]\+ [KMG]B/s'"

for test in ${TESTS}; do
    if [ "${test}" = "seq" -o "${test}" = "rand" ]; then
        TEST_TYPE=$test
    else
        echo "${TEST_TYPE} write (${test}b block):"
        [ "${TEST_TYPE}" = "seq" ] && echo "  $(eval ${SEQ_WRITE_CMD}${test}${PIPE_CMD})"
        [ "${TEST_TYPE}" = "rand" ] && echo "  $(eval ${RAND_WRITE_CMD}${test}${PIPE_CMD})"
        echo "${TEST_TYPE} read (${test}b block):"
        echo "  $(eval ${READ_CMD}${test}${PIPE_CMD})"
    fi
done

rm -f "${FULL_PATH}"
echo -e "\nDone.\n"

exit $?
