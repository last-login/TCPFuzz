TCPFuzz
=======

A TCP Stateful Fuzzer

This fuzzer can be used for penetration and regression tests of TCP implementations.

It consists of three programs:

- The Fuzzer, for creating testcases
- The client (Python, Perl and C implementations. C is not functional at the moment.), which runs on the target system.
- The testcase-interpreter.

Requirements
------------

- Python 3.7+
- Dependencies: `pip install -r requirements.txt` (scapy, PyYAML)

Quick start
-----------

Generate testcases (optionally with an OS profile):

    ./tcpfuzzer -n 10 -P profile_OBSD.yaml -f test_auto.yaml

Run the testcases against the target (needs a running client on the target
system, a valid `config.yaml` and root privileges for raw packet injection):

    sudo ./runtcptest -f config.yaml -t test_auto.yaml

See the manpages in man/ and the source for further information.
