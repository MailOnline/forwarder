for i in {1..10}; do log_random >> myapp.log; done

assert "sender -p offsets 'myapp.*' | count_lines" 10

mv myapp.log myapp.log.1

log_random >> myapp.log

assert "sender -p offsets 'myapp.*' | count_lines" 1
