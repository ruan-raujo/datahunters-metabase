#!/bin/sh
set -u

show_memory() {
    for memory_file in \
        /sys/fs/cgroup/memory.max \
        /sys/fs/cgroup/memory.current \
        /sys/fs/cgroup/memory.peak \
        /sys/fs/cgroup/memory.events \
        /sys/fs/cgroup/memory/memory.limit_in_bytes \
        /sys/fs/cgroup/memory/memory.failcnt
    do
        if [ -r "$memory_file" ]; then
            printf '[diagnostico] %s:\n' "$memory_file"
            cat "$memory_file" || true
        fi
    done
}

printf '[diagnostico] Memoria antes de iniciar o Metabase:\n'
show_memory

java -XX:+IgnoreUnrecognizedVMOptions \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    -jar /app/metabase.jar "$@" &
java_pid=$!

# Forward shutdown signals to Java and preserve the container exit status.
trap 'kill -TERM "$java_pid" 2>/dev/null; wait "$java_pid"; exit 143' TERM
trap 'kill -INT "$java_pid" 2>/dev/null; wait "$java_pid"; exit 130' INT

wait "$java_pid"
exit_code=$?
printf '[diagnostico] Java encerrou com codigo %s\n' "$exit_code"
show_memory
exit "$exit_code"
