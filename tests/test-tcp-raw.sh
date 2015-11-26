for i in {1..10}; do log_random >> myapp.log; done

nc -l -p 19501 2>/dev/null > received.log || nc -l 19501 > received.log 2>/dev/null & 

server_pid=$!

sleep 0.1

sender 'myapp.*' -t localhost:19501

assert "count_lines received.log" 10

kill -9 $server_pid &> /dev/null || true
