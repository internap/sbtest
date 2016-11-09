#!/bin/bash
set -e

fail() {
    printf "Failure: ${@}\n" > /dev/stderr
    exit 1
}


if [ -z "${RUN_SINGLE_TEST:-""}" ]; then
  TEST_ROOT="test"
  SOURCE_ROOT=${1:-"src"}
  for f in $(find ${TEST_ROOT} -name "test_*"); do
    RUN_SINGLE_TEST=1 $0 ${SOURCE_ROOT} ${f} || fail "${f} failed."
  done
  exit 0
fi

export PS4='+ ${BASH_SOURCE:-}:${FUNCNAME[0]:-}:L${LINENO:-}:   '
SOURCE_ROOT=$1
TEST_FILE=$2

source ${TEST_FILE} || fail "Unable to read ${TEST_FILE}."

all_functions=$(typeset -F | sed "s/declare -f //")
tests=$(echo "${all_functions}" | grep "^test_" || true)
setup=$(echo "${all_functions}" | grep "^setup$" || true)
teardown=$(echo "${all_functions}" | grep "^teardown" || true)


assert_int() {
    local actual=$1
    local expected=$2

    test ${actual} -eq ${expected} || fail "Expected <$expected>\nGot:      <$actual>"
}


mock-exitcode() {
    return_code=$1
    cat <<EOF
#!/bin/bash
exit ${return_code}
EOF
}


mock() {
    local expected_args=""
    local mock_type=""
    local and_params=""

    local executable=$1; shift;
    if [ $1 == "--with-args" ]; then
        expected_args=$2; shift; shift;
    fi
    if [ $1 == "--and" ]; then
        mock_type=$2; shift; shift;
        and_params=$@
    fi

    if [ -n "${expected_args}" ]; then
        _mock_assert_args "${expected_args}" ${mocks}/${executable}-then > ${mocks}/${executable}
        mock ${executable}-then --and exitcode "${and_params}"
    else
        mock-${mock_type} "${and_params}" > ${mocks}/${executable}
    fi
    chmod +x ${mocks}/${executable}
}


_mock_assert_args() {
    expected_args=$1
    and=$2
    cat <<EOF
#!/bin/bash
args=\$@
if [ "\$args" == "${expected_args}" ]; then
    ${and}
else
    echo "Args [\$args] did not match [${expected_args}]" > expectation_failure
fi
EOF
}


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
    popd
done

trap - INT TERM EXIT
