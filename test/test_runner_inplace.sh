
test_inplace_mode_runs_inplace() {
    unset RUN_SINGLE_TEST

    ${TEST_ROOT_DIR}/../target/sbtest.sh --inplace --src ${TEST_ROOT_DIR}/../test-fixtures/inplace-test/src --tests ${TEST_ROOT_DIR}/../test-fixtures/inplace-test/test
    assert ${?} succeeded
}
