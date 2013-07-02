TCPFuzz
=======

A TCP Stateful Fuzzer

This fuzzer can be used for penetration and regression tests of TCP implementations.
It consists of three programs:

- The Fuzzer, for creating testcases
- The client (Python, Perl and C implementations. C is not functional at the moment.), which runs on the target system.
- The testcase-interpreter.

See the manpages in man/ and the source for further information.
