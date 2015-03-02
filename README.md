forwarder
=========

Monitor log files and forward their content to either stdout or network.

After sucessfully forward the new content, it saves the offset of the files in the OFFSETS file. So to continue where it left off after a restart.


Usage
-----

```
$ ./sender -h
Usage: sender [options] <pattern0> ... <patternN>

Outputs the content of files resolved by the patterns passed as parameters and
keep monitoring them for new content. Optionally the offsets can be writen to
the <offsets> file. Which will be read when starting. IMPORTANT: only files
with size >= signature-length (default 50) bytes will be processed. Zip files
will be open recursively, and only once.

Options:
  -h, --help            show this help message and exit
  -f, --follow          Pools the file very second for changes in an infinite
                        loop.
  -p OFFSETS, --offsets=OFFSETS
                        File to persist the last offsets read for each file.
                        If it doesn't exist, the files are read from
                        beginning.
  -t HOST:PORT, --tcp=HOST:PORT
                        Sends the output to the host:port via TCP.
  -s BYTES, --signature-length=BYTES
                        First BYTES of the each file will be used as it's ID
                        in offsets file, so the files can be renamed not
                        losing the offset. Default is 50.
  -g STARTING, --greater-or-equal-than=STARTING
                        Only copy lines which are >= than STARTING in
                        lexicographical order. In lines starting with
                        datetime, this can be used to ignore older events.
  -e, --start-from-the-tail
                        Generate offsets file at the tail of every file.
                        Useful if you want to start following the end of all
                        files returned in pattern. .. Well, ask Fabio.
  -l FILTER, --filter=FILTER
                        Command or shell script that will filter the events
                        using stdin and stdout.
  -r, --retry-on-network-error
                        Keep trying to reconnect instead of exiting with an
                        error.
```


Filters
-------

You can pass filters that will receive new content line by line, and its output will be forwarded instead of the original content.

Examples:

This will remove all lines with TRACE in it from the output
```
$ ./sender /path/to/mylog.log -l 'grep --line-buffer -v TRACE'
```

Important: some posix tools like `grep` by default only flush after every line if the output is TTY (user interactive session), and disable it otherwise. For so we use a `grep --line-buffer` to force it to flush after evert line, so we won't lose the lines kept in its internal buffers in case of a restart.

The argument passed to filter will be run with `sh -c`, which means you can pass any bash script there or chain multiple commands using pipe, like:
```
$ ./sender /path/to/mylog.log -l "grep --line-buffer MY_LOGS | awk '{print \$2}'"
```

Notice the above example escapes the `$`, because we're using double codes for the argument and we want to keep bash from resolving `$2`.


Network Protocol
----------------

Well, this is pretty "protocol-less", in the sense that when forwarding to a tcp address it will just open the connection and output raw traffic in the same way [netcat](http://en.wikipedia.org/wiki/Netcat) does.

