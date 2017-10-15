#! /usr/bin/env perl6

use v6.c;
use lib "lib";
use Test;

plan 1;

use MPD::Client;
use MPD::Client::Control;

my $socket = mpd-connect(host => "localhost");

isa-ok $socket, "IO::Socket::INET", "mpd-connect returns a socket";
