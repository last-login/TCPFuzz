#!/usr/bin/perl 
######################################################################
# Copyright (C) 2013 GeNUA mbH, 85551 Kirchheim, Germany.
# All rights reserved.  Alle Rechte vorbehalten.
######################################################################

use strict;
use warnings;
use Socket;
use IO::Select;
use POSIX;
use feature 'switch';

my $BUFSIZE = 4096;

sub fuzzsock {
  my $sock = shift;
  my $proto = getprotobyname('tcp');
  socket($sock, AF_INET, SOCK_STREAM, $proto)
    or die "Could not create socket: $!";
  setsockopt($sock, SOL_SOCKET, SO_REUSEADDR, 1);
  fcntl($sock, F_SETFL(), O_NONBLOCK());
  return $sock;
}

sub main {
  my %verbs = ('accept' => 1, 'connect' => 1, 'close' => 1, 'bind' => 1, 'sendto' => 1,
    'listen' => 1, 'recv' => 1, 'send' => 1, 'setsockopt' => 1, 'status' => 1, 'reset' => 1);
  my $port = $ARGV[0];
  print "This is the Fuzzing Client\n";
  my $proto = getprotobyname('tcp');
  socket(my $sock_control, AF_INET, SOCK_STREAM, $proto)
    or die "Could not create socket: $!";
  bind($sock_control, sockaddr_in($port, INADDR_ANY)) or die "bind failed: $!";
  listen($sock_control, 5) or die "listen failed: $!";
  setsockopt($sock_control, SOL_SOCKET, SO_REUSEADDR, 1) or die "Setsockopt failed: $!";
  print "Listening on port $port\n";
  my $sock;
  my $select = IO::Select->new();
  $select->add($sock_control);
  my ($contr_port, $addr);
  my $conn_control;
  my $conn;
  while(1) {
    my @ready = $select->can_read(500);
    foreach my $r (@ready) {
      if ($r == $sock_control) {
        accept($conn_control, $sock_control);
        $select->add($conn_control);
        my $iaddr = getpeername($conn_control);
        ($contr_port, $addr) = sockaddr_in($iaddr);
        $sock = fuzzsock($sock);
        print "Connection from: ".inet_ntoa($addr)." ".$contr_port."\n";
      } else {
        recv($r, my $msg, $BUFSIZE, 0);
        if (!$msg) {
          $select->remove($r);
          close($r);
          print "closed control connection\n";
          close($sock);
          $sock = fuzzsock($sock);
          next;
        }
        my @cmds = $msg =~ /(\S+)/g;
        my $verb = $cmds[0] if $cmds[0] or next;
        my $arg = $cmds[1] if $cmds[1];
        if (exists $verbs{$verb}) {
          given ($verb) {
            when ('accept') {
              if (accept($sock, $sock)) {
                send($conn_control, "accept OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('connect') {
              if (connect($sock, sockaddr_in($arg, $addr))) {
                send($conn_control, "connect OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('close') {
              if (close($sock)) {
                $sock = fuzzsock($sock);
                send($conn_control, "close OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('bind') {
              if (bind($sock, sockaddr_in($arg, INADDR_ANY))) {
                send($conn_control, "bind OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('listen') {
              if (listen($sock, 1)) {
                send($conn_control, "listen OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('recv') {
              if (recv($sock, my $recv_msg, $BUFSIZE, 0)) {
                send($conn_control, "recv OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('send') {
              if (send($sock, $arg, 0)) {
                send($conn_control, "send OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }   
            }
            when ('sendto') {
              if (send($sock, $arg, 0, sockaddr_in($arg, $addr))) {
                send($conn_control, "sendto OK\n", 0);
              } else {
                send($conn_control, $!."\n", 0);
              }
            }
            when ('reset') {
              close($sock);
              send($conn_control, "reset OK\n", 0);
              $sock = fuzzsock($sock);
            }
            default {next;}
          }
        }
      }
    }
  }
}

&main();
