for i in {1..10}; do log_random >> a.log; done

assert "sender -p offsets '*.log' | count_lines" 10

log_random >> a.log

mv a.log b.log

for i in {1..20}; do log_random >> a.log; done

assert "sender -p offsets '*.log' | count_lines" 21
