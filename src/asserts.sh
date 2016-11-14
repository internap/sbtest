
assert() {
    local actual=$1
    local directive=$2
    local expected=$3

    _assert_${directive} "${actual}" "${expected}"
}

_assert_equals() {
    test "${1}" == "${2}" || assertion_failed "Expected: <$2>\nGot:      <$1>"
}

_assert_succeeded() {
    test ${1} -eq 0 || assertion_failed "Expected success exit code\nGot: <$1>"
}

_assert_failed() {
    test ${1} -ne 0 || assertion_failed "Expected failure exit code\nGot: <$1>"
}
