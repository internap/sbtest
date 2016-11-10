
assert_int() {
    local actual=$1
    local expected=$2

    test ${actual} -eq ${expected} || fail "Expected <$expected>\nGot:      <$actual>"
}
