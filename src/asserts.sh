
assert() {
    local actual=$1
    local directive=$2
    local expected=$3

    _assert_${directive} "${actual}" "${expected}"
}

_assert_equals() {
    test "${1}" == "${2}" || fail "Expected <$2>\nGot:      <$1>"
}

_assert_succeeded() {
    test ${1} -eq 0 || fail "Expected success exit code\nGot:      <$1>"
}

_assert_failed() {
    test ${1} -ne 0 || fail "Expected failure exit code\nGot:      <$1>"
}
