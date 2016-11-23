
fail() {
    printf "Failure: ${@}\n" > /dev/stderr
    exit 1
}

_format_count() {
    if [ ${1} == 1 ]; then
        echo "${1} ${2}"
    else
        echo "${1} ${2}s"
    fi
}

_trim_test_prefix() {
    echo "$1" | sed 's/^test_//'
}

_file_base_name() {
    echo ${1%.*}
}

_abs() {
  ( cd "$(dirname "${1}")"; echo "${PWD}/$(basename "${1}")" )
}
