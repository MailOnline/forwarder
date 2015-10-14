for i in {1..10}; do log_random >> myapp.log; done

if [ `uname` = "Darwin" ]; then
	nc -l -p 19501 > received.log & 
else 
	nc -l 19501 > received.log &
fi

server_pid=$!

sleep 0.1

sender 'myapp.*' -t localhost:19501

assert "count_lines received.log" 10

kill -9 $server_pid &> /dev/null || true
