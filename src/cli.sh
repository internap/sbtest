
if [ -z "${RUN_SINGLE_TEST:-""}" ]; then

    sources_root="src"
    test_sources_root="test"
    test_suites_filter="test_*"
    test_filter="^test_"

    while [[ $# -gt 0 ]]; do
        key="$1"

        case ${key} in
            --src)
            sources_root="$2"; shift
            ;;
            --tests)
            test_sources_root="$2"; shift
            ;;
            *)
            if [[ ${key} == *"."* ]]; then
                test_filter="^test_${key##*.}$"
                key=${key%.*}
            fi
            test_suites_filter="test_${key}.sh"
            ;;
        esac
        shift
    done

    sources_root=$(_abs ${sources_root})
    test_sources_root=$(_abs ${test_sources_root})

    echo ""
    echo "Running Simple Bash Tests"
    echo "-------------------------"
    echo ""

    registry="$(mktemp -d "/tmp/workspace.registry.XXXXXXXX")"
    test_count=0

    for f in $(find ${test_sources_root} -name "${test_suites_filter}" | sort); do
        TEST_ROOT_DIR=${test_sources_root} RUN_SINGLE_TEST=1 $0 ${sources_root} ${f} ${test_filter} ${registry} || fail "${f} failed."

        new_tests=$(cat ${registry}/test_count)
        test_count=$((${test_count} + ${new_tests}))
    done

    if [ -f ${registry}/failures_output ]; then
        cat ${registry}/failures_output
    fi

    echo ""
    echo "-------------------------"
    echo "Ran "$(_format_count ${test_count} "test")
    echo ""

    failure_count=$(cat ${registry}/failures_count)
    if [ ${failure_count} -eq 0 ]; then
        echo ">>> SUCCESS <<<"
        echo ""
        exit 0
    else
        echo ">>> FAILURE ("$(_format_count ${failure_count} "problem")") <<<"
        echo ""
        exit 1
    fi
fi
