echo "AAAAAAAAAAAAAAAAAA BBBBBBBBBBBBBBB" > myapp.log
echo "AAAAAAAAAAAAAAAAAA CCCCCCCCCCCCCCC" > myapp.log.1

assert "sender -s 15 'myapp.*' | count_lines" 1
assert "sender -s 30 'myapp.*' | count_lines" 2
