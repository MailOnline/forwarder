for i in {1..10}; do log_random >> myapp.log; done
assert_raises "[ $(count_bytes myapp.log) -gt 256 ]"

assert "sender -p offsets 'myapp.*' | count_lines" 10

log_random >> myapp.log
assert "sender -p offsets 'myapp.*' | count_lines" 1

log_random >> myapp.log
gzip myapp.log

assert "sender -p offsets 'myapp.*' | tee sent.log | count_lines" 1
assert_raises "cat sent.log | grep $(last_uuid)"
assert "sender -p offsets 'myapp.*' | count_lines" 0
