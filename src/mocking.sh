
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
