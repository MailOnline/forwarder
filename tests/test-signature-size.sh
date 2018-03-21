echo "AAAAAAAAAAAAAAAAAA BBBBBBBBBBBBBBB" > myapp.log
echo "AAAAAAAAAAAAAAAAAA CCCCCCCCCCCCCCC" > myapp.log.1

assert "sender -s 15 'myapp.*' | count_lines" 0
assert "sender -s 30 'myapp.*' | count_lines" 2

echo "AAAAAAAAAAAAAAAAAA DDDDDDDDDDDDDDD" > myapp.log.2
echo "AAAAAAAAAAAAAAAAAA DDDDDDDDDDDDDDD" > myapp.log.3
echo "AAAAAAAAAAAAAAAAAA DDDDDDDDDDDDDDD" > myapp.log.4
echo "AAAAAAAAAAAAAAAAAA DDDDDDDDDDDDDDD" > myapp.log.5

assert "sender -s 30 'myapp.*' | count_lines" 2

assert "sender -s 30 'myapp.*' 2>&1 | grep forwarder.duplicatesig | count_lines" 3
