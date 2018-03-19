
for i in {1..10}; do log_random >> myapp.log; done

uuid=$(last_uuid)

sender -f 'myapp.*' -l "grep --line-buffered -v ${uuid}" > /dev/null &
sender_pid=$!
sleep 0.1 # to avoid race condition

assert "ps ax | grep ${uuid} | grep -v sender | grep -v filter_wrapper | grep line-buffered | count_lines" 1

kill -SIGTERM $sender_pid

wait $sender_pid

assert "ps ax | grep ${uuid} | grep line-buffered | count_lines" 0
