#!/bin/bash

test_can_specify_alternative_paths_src() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --src not-src \
                --tests not-test)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_specify_alternative_relative_paths_src() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --src ./unconventional-test/not-src \
                --tests ./unconventional-test/not-test)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_specify_alternative_absolute_paths_src() {
    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --src ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/not-src \
                --tests ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/not-test)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}
