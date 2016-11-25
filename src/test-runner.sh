
SOURCE_ROOT=$1
TEST_FILE=$2
TESTS_FILTER=$3
REGISTRY=$4

source ${TEST_FILE} || fail "Unable to read ${TEST_FILE}."

all_functions=$(typeset -F | sed "s/declare -f //")
tests=$(echo "${all_functions}" | grep ${TESTS_FILTER} || true)
setup=$(echo "${all_functions}" | grep "^setup$" || true)
teardown=$(echo "${all_functions}" | grep "^teardown" || true)


_setup_workspace() {
    workspace="$(mktemp -d "/tmp/workspace.$(basename ${TEST_FILE}).XXXXXXXX")"
    cp -aR ${SOURCE_ROOT}/* ${workspace}/

    mocks="$(mktemp -d "${workspace}/mocks.XXXXXXXX")"
    original_path=${PATH}
    export PATH="$mocks:${PATH}"
}

_problem_report() {
    type=$1
    test=$2
    workspace=$3

    cat <<FAILURE

=========================
${type}: ${test}
-------- STDOUT ---------
$(cat ${workspace}/test_output)
-------- STDERR ---------
$(cat ${workspace}/test_output_err)
-------------------------
FAILURE
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

test_count=0
failures=0

assertion_failed() {
    touch ${workspace}/.assertion_error
    echo -e "$1"
    return 1
}

for test in ${tests}; do
    _setup_workspace

    pushd ${workspace} >/dev/null

    if [ -n ${setup} ]; then
        ${setup}
    fi

    test_name=$(_trim_test_prefix $(_file_base_name $(basename ${TEST_FILE}))).$(_trim_test_prefix ${test})
    printf ${test_name}...

    failed=0

    ${test} >${workspace}/test_output 2>${workspace}/test_output_err || error_code=${?}

    if [ -f ${workspace}/.assertion_error ]; then
        echo "FAILED"
        failures=$((${failures} + 1))
        _problem_report "FAIL" ${test_name} ${workspace} >> ${REGISTRY}/failures_output
    elif [ -n "${error_code}" ]; then
        echo "ERROR"
        failures=$((${failures} + 1))
        echo "EXIT CODE : ${error_code}" >> ${workspace}/test_output_err
        _problem_report "ERROR" ${test_name} ${workspace} >> ${REGISTRY}/failures_output
    else
        echo "OK"
    fi
    test_count=$((${test_count} + 1))

    _cleanup
    popd >/dev/null
done

echo ${test_count} > ${REGISTRY}/test_count
echo ${failures} > ${REGISTRY}/failures_count

trap - INT TERM EXIT
