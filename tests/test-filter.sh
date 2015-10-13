for i in {1..10}; do log_random >> myapp.log; done

log_random >> myapp.log
uuid=$(last_uuid)
log_random >> myapp.log
log_random >> myapp.log

assert "sender 'myapp.*' -l 'grep -v $uuid' | count_lines" 12
assert "sender 'myapp.*' -l 'grep $uuid' | count_lines" 1
