zip --version &> /dev/null || echo zip utility not found, please install it before running tests

for i in {1..10}; do log_random >> myapp.log; done

assert "sender -p offsets 'myapp.*' | count_lines" 10

log_random >> myapp.log

zip myapp.zip myapp.log &> /dev/null

assert "sender -p offsets 'myapp.*' | count_lines" 1
assert "sender -p offsets 'myapp.*' | count_lines" 0
