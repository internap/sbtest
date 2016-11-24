action-echo() {
    text="$@"
    cat <<EOF
echo "${text}"
EOF
}

action-exit-code() {
    return_code=$1
    cat <<EOF
exit ${return_code}
EOF
}

validate-args() {
    expected="$@"
    cat <<EOF
args="\$@"

if [ "\${args}" != "${expected}" ]; then

    cat <<OUT
Unexpected invocation for command 'some-command':
Got :      <"\${args}">
Expected : <"${expected}">
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
        esac
        shift
    done

    mock_workspace="${mocks}/_${executable}.workspace"

    if [ ! -d ${mock_workspace} ]; then
        mkdir -p ${mock_workspace}
        echo "1" > ${mock_workspace}/invocation_index

        _mock_handler ${mock_workspace} > ${mocks}/${executable}
        chmod +x ${mocks}/${executable}

        invocation_count=1
    else
        ((invocation_count=$(cat ${mock_workspace}/invocation_count) + 1))
    fi

    echo ${invocation_count} > ${mock_workspace}/invocation_count
    invocation_file="${mock_workspace}/invocation_${invocation_count}"

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

\${workspace}/invocation_\${invocation_index} \${args}
EOF
}
