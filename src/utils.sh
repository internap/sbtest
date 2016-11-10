
fail() {
    printf "Failure: ${@}\n" > /dev/stderr
    exit 1
}
