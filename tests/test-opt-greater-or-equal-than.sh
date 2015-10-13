for i in {1..10}; do log_random >> myapp.log; done

log_random >> myapp.log
ts=$(last_timestamp)
log_random >> myapp.log
log_random >> myapp.log

assert "sender -g '$ts' 'myapp.*' | count_lines" 3
assert "sender --greater-or-equal-than '$ts' -p offsets 'myapp.*' | count_lines" 3
assert "sender --greater-or-equal-than '$ts' -p offsets 'myapp.*' | count_lines" 0
assert "sender -p offsets 'myapp.*' | count_lines" 0
