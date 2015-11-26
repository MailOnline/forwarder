for i in {1..10}; do log_random >> myapp.log; done

assert "sender -p offsets 'myapp.*' | count_lines" 10

mv myapp.log myapp.log.1

assert "sender -p offsets 'myapp.*' | count_lines" 0

log_random >> myapp.log.1

mv myapp.log.1 myapp.log.2

assert "sender -p offsets 'myapp.*' | count_lines" 0
