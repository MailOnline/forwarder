for i in {1..10}; do log_random >> myapp.log; done
nc --version

netcat -l -p 19501 > received.log &
server_pid=$!

sleep 0.1

sender 'myapp.*' -t localhost:19501

assert "count_lines received.log" 10
