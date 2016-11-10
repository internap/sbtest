
if [ -z "${RUN_SINGLE_TEST:-""}" ]; then
  TEST_ROOT="test"
  SOURCE_ROOT=${1:-"src"}
  for f in $(find ${TEST_ROOT} -name "test_*"); do
    RUN_SINGLE_TEST=1 $0 ${SOURCE_ROOT} ${f} || fail "${f} failed."
  done
  exit 0
fi


SOURCE_ROOT=$1
TEST_FILE=$2

source ${TEST_FILE} || fail "Unable to read ${TEST_FILE}."

all_functions=$(typeset -F | sed "s/declare -f //")
tests=$(echo "${all_functions}" | grep "^test_" || true)
setup=$(echo "${all_functions}" | grep "^setup$" || true)
teardown=$(echo "${all_functions}" | grep "^teardown" || true)


_setup_workspace() {
    workspace="$(mktemp -d "/tmp/workspace.$(basename ${TEST_FILE}).XXXXXXXX")"
    cp -aR ${SOURCE_ROOT}/* ${workspace}/

    mocks="$(mktemp -d "${workspace}/mocks.XXXXXXXX")"
    original_path=${PATH}
    export PATH="$mocks:${PATH}"
}


_cleanup() {
    if [ -n ${teardown} ]; then
        ${teardown}
    fi

    export PATH="${original_path}"
    expectation_failure=$(cat ${workspace}/expectation_failure 2>/dev/null || true)

    rm -rf ${workspace}

    if [ -n "${expectation_failure}" ]; then
        echo "FAILURE : ${expectation_failure}"
        exit 1
    fi
}

trap _cleanup INT TERM EXIT

for test in ${tests}; do
    _setup_workspace

    pushd ${workspace} >/dev/null

    if [ -n ${setup} ]; then
        ${setup}
    fi

    printf "Running test ${test}..."
    ${test} || fail "Test failed with exit code $?"
    echo "ok"

    _cleanup
    popd >/dev/null
done

trap - INT TERM EXIT
