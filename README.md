forwarder
=========

Monitor log files and forward their content to either stdout or network.

After successfully forward the new content, it saves the offset of the files in the OFFSETS file. So to continue where it left off after a restart.

The network output can be used to send events to [Splunk](http://www.splunk.com/)


Why another one?
----------------

Because we needed a tool that could run solely on Python 2.4

Requirement
-----------

- Python >= 2.4


Usage: `sender`
---------------

```
Usage: sender [options] <pattern0> ... <patternN>

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
  -i FILE, --dump-pid=FILE
                        Write process id to this file. Disabled by default.
  -k FILE, --kill=FILE  Send SIGTERM to process id saved in FILE and exit
```

Example
-------

```
$ sender -i ~/services-sender.pid '/service/*/log/current' \
    -p ~/services-offsets -t 10.0.0.1:7878 \
    -r -f -l 'grep --line-buffer -v TRACE' 
```

This will save it's process id to `~/services-sender.pid` file, then keeps checking every second for changes in all `/service/*/log/current` files and send its content to the tcp address `10.0.0.1:7878` after it is filtered by `grep --line-buffer -v TRACE`, and it will keep retrying in case of network failure.


How does it work?
-----------------

Every second `sender` will open all files it monitors that the size is >= than the signature-length, seek to last offset known, and tries to read more bytes. If there is new content, it will send either to stdout or network or the filter.

If a filter has been specified, the new content sent to it, and then the filter's result is gonna be output.

After the new content is successfully sent either to stdout, network or filter, the OFFSETS file is recreated with the last known offsets of each file.

#### Signals

Upon receiving a SIGINT or SIGTERM signals, `sender` will stop processing the files, save whatever OFFSET it has already succefully sent to output, close the filter's stdin, and then wait for the filter to finish. Only then it will actually exit.


#### Signature

`sender` uses the *signature* instead of filename to identify the file. And the *signature* is the md5 of the first `signature-length` bytes, which defaults to 50 bytes. This way the file can be renamed (rolled), and it's content won't be processed again.

#### Zip Files

Zip files will be open and processed only once. `sender` will unzip them to a temp folder and each file will be recursively processed as if it was a normal file (trying to match it's signature with the persisted OFFSETS file). After all files are processed, the temp folder is removed and a single entry is added to the OFFSETS file for the zip one.


Filters
-------

You can pass filters that will receive new content line by line, and its output will be forwarded instead of the original content.

Examples:

This will remove all lines with TRACE in it from the output
```
$ ./sender /path/to/mylog.log -l 'grep --line-buffer -v TRACE'
```

**Important**: tools like `grep` usually by default flush after every line only if the output is a TTY (user interactive session), and disable it otherwise. For the example uses use the option `--line-buffer` to force grep to flush after every line, so we won't lose the lines kept in its internal buffers in case of a restart.

The argument passed to filter will be run with `sh -c`, which means you can pass any bash script there or chain multiple commands using pipe, like:
```
$ ./sender /path/to/mylog.log -l "grep --line-buffer MY_LOGS | awk '{print \$2}'"
```

Notice the above example escapes the `$`, because we're using double codes for the argument and we want to keep bash from resolving `$2`.

Filter Wrapper
--------------

`filter_wrapper` is used by `sender` to actually run the filter. Before it does so, `filter_wrapper` puts itself in a different process group, ensuring then it won't receive posix signals sent to its parent. This way, if a SIGINT or SIGTERM is sent to `sender`, it has the chance to gracefully close the filter's stdin and let it flushes whatever internal buffer may keep.

Note that when using it with service managers like **Solaris SMF**, the standard `:kill` method to stop a service sends a SIGTERM to all the processes started by this service, not only the ones in the same processes group. For that case, you can use the same `sender` in the SMF stop method, using the option `-k` to send the SIGTERM to current sender.


Network Protocol
----------------

Well, this is pretty "protocol-less", in the sense that when forwarding to a tcp address it will just open the connection and output raw traffic in the same way [netcat](http://en.wikipedia.org/wiki/Netcat) does.


License
-------

Copyright © 2015 Mailonline

Distributed under the Eclipse Public License either version 1.0
