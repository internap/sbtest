
_format_count() {
    if [ ${1} == 1 ]; then
        echo "${1} ${2}"
    else
        echo "${1} ${2}s"
    fi
}

_trim_test_prefix() {
    echo "$1" | sed 's/^test_//'
}

_file_base_name() {
    echo ${1%.*}
}

if [ -z "${RUN_SINGLE_TEST:-""}" ]; then
  TEST_ROOT="test"
  SOURCE_ROOT=${1:-"src"}

  echo ""
  echo "Running Simple Bash Tests"
  echo "-------------------------"
  echo ""

  registry="$(mktemp -d "/tmp/workspace.registry.XXXXXXXX")"
  test_count=0

  for f in $(find ${TEST_ROOT} -name "test_*"); do
    TEST_ROOT_DIR=$PWD/${TEST_ROOT} RUN_SINGLE_TEST=1 $0 ${SOURCE_ROOT} ${f} ${registry} || fail "${f} failed."

    new_tests=$(cat ${registry}/test_count)
    test_count=$((${test_count} + ${new_tests}))
  done

  echo ""
  echo "-------------------------"
  echo "Ran "$(_format_count ${test_count} "test")
  echo ""
  echo ">>> SUCCESS <<<"
  echo ""
  exit 0
fi


SOURCE_ROOT=$1
TEST_FILE=$2
REGISTRY=$3

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

test_count=0

for test in ${tests}; do
    _setup_workspace

    pushd ${workspace} >/dev/null

    if [ -n ${setup} ]; then
        ${setup}
    fi

    printf $(_trim_test_prefix $(_file_base_name $(basename ${TEST_FILE}))).$(_trim_test_prefix ${test})...
    ${test} || fail "Test failed with exit code $?"
    echo "OK"
    test_count=$((${test_count} + 1))

    _cleanup
    popd >/dev/null
done

echo ${test_count} > ${REGISTRY}/test_count

trap - INT TERM EXIT
