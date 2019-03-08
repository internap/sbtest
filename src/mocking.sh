action-cat() {
    path="$@"
    cat <<EOF
cat "${path}"
EOF
}

action-cat-stderr() {
    path="$@"
    cat <<EOF
cat "${path}" > /dev/stderr
EOF
}

action-echo() {
    text="$@"
    cat <<EOF
echo "${text}"
EOF
}

action-echo-stderr() {
    text="$@"
    cat <<EOF
echo "${text}" > /dev/stderr
EOF
}

action-exit-code() {
    return_code=$1
    cat <<EOF
exit ${return_code}
EOF
}

validate-args() {
    file="$(pwd)/validate-args-expected-${RANDOM}${RANDOM}"
    echo "$@" > ${file}

    cat <<EOF
args="\$@"
if [ "\${args}" != "\$(cat ${file})" ]; then
    cat <<OUT
Unexpected invocation for command 'some-command':
Got :      <"\${args}">
Expected : <"\$(cat ${file})">
OUT
    exit 1
fi
EOF
}

mock() {
    local executable=$1; shift
    local actions=()
    local actions_params=()
    local action_count=0
    local has_args_validation=false
    local expected_calls=-1 #any

    while [[ $# -gt 0 ]]; do
        local key="$1"

        case ${key} in
            --and)
            actions[$action_count]="action-$2"
            actions_params[$action_count]="$3"
            shift; shift
            ((action_count=action_count + 1))
            ;;
            --with-args)
            if [ ${has_args_validation} == false ]; then
                actions[$action_count]="validate-args"
                actions_params[$action_count]="$2"; shift
                ((action_count=action_count + 1))
                has_args_validation=true
            else
                echo "Cannot expect more than 1 set of argument for an invocation, please use 'mock' multiple times"
                return 1
            fi
            ;;
            --once)
            expected_calls=1
            ;;
        esac
        shift
    done

    mock_workspace="${mocks}/_${executable}.workspace"

    if [ ! -d ${mock_workspace} ]; then
        mkdir -p ${mock_workspace}
        echo "1" > ${mock_workspace}/invocation_index

        if [ -n "${executable%%*/*}" ]; then
            _mock_handler ${mock_workspace} > ${mocks}/${executable}
            chmod +x ${mocks}/${executable}
        else
            mkdir -p $(dirname ${executable})
            _mock_handler ${mock_workspace} > ${executable}
            chmod +x ${executable}
        fi

        invocation_count=1
    else
        ((invocation_count=$(cat ${mock_workspace}/invocation_count) + 1))
    fi

    echo ${invocation_count} > ${mock_workspace}/invocation_count
    invocation_file="${mock_workspace}/invocation_${invocation_count}_code"

    echo 0 > "${mock_workspace}/invocation_${invocation_count}_calls"
    echo ${expected_calls} > "${mock_workspace}/invocation_${invocation_count}_expected_calls"

    echo "#!/bin/bash" > ${invocation_file}

    for i in ${!actions[@]}; do
        ${actions[$i]} ${actions_params[$i]} >> ${invocation_file}
    done

    chmod +x ${invocation_file}
}

_mock_handler() {
    cat <<EOF
#!/bin/bash
args="\$@"

workspace=$1

invocation_index=\$(cat \${workspace}/invocation_index)

if [ \${invocation_index} -lt \$(cat \${workspace}/invocation_count) ]; then
    echo \$((invocation_index + 1)) > \${workspace}/invocation_index
fi

invocation_calls=\$(cat \${workspace}/invocation_\${invocation_index}_calls)
echo \$((invocation_calls + 1)) > \${workspace}/invocation_\${invocation_index}_calls

expected_calls=\$(cat \${workspace}/invocation_\${invocation_index}_expected_calls)
if [ \${expected_calls} -ge 0 ] && [ \$((invocation_calls + 1)) -gt \${expected_calls} ]; then
    exit 1
fi

\${workspace}/invocation_\${invocation_index}_code \${args}
EOF
}

_verify_mocks() {
    for mock in $(find ${mocks} -type d -maxdepth 1 -name "_*.workspace" 2>/dev/null || true); do
        command=$(echo ${mock} | sed 's/.*\/_//' | sed 's/.workspace//')

        for invocation in $(find ${mock} -maxdepth 1 -name "invocation_*_code" 2>/dev/null || true); do
            invocation_id=$(echo ${invocation} | sed 's/.*\/invocation_//' | sed 's/_code//')
            call_count=$(cat ${mock}/invocation_${invocation_id}_calls)
            expected_calls=$(cat ${mock}/invocation_${invocation_id}_expected_calls)

            if [ ${expected_calls} -ge 0 ] && [ ${call_count} -ne ${expected_calls} ]; then
                assertion_failed "Command '${command}' was expected to be called $(_format_count ${expected_calls} "time")\nCalled : $(_format_count ${call_count} "time")"
            fi
        done
    done
}
