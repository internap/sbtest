
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

mock() {
    local executable=$1; shift
    local actions=()
    local actions_params=()
    local action_count=0

    while [[ $# -gt 0 ]]; do
        key="$1"

        case ${key} in
            --and)
            actions[$action_count]="$2"
            actions_params[$action_count]="$3"
            shift; shift
            ((action_count=action_count + 1))
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

    for i in ${!actions[@]};
    do
        action-${actions[$i]} ${actions_params[$i]} >> ${invocation_file}
    done

    chmod +x ${invocation_file}
}

_mock_handler() {
    cat <<EOF
#!/bin/bash
workspace=$1
invocation_index=\$(cat \${workspace}/invocation_index)

if [ \${invocation_index} -lt \$(cat \${workspace}/invocation_count) ]; then
    echo \$((invocation_index + 1)) > \${workspace}/invocation_index
fi

\${workspace}/invocation_\${invocation_index}
EOF
}
