#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

plan 3;

say "testing LogCatcher";

use Net::ZMQ::Context:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');

use Log::ZMQ::LogCatcher;
use Log::ZMQ::Logger;

my $prefix = 'test';
my $logsys = Logging::instance( $prefix );
my $logger = $logsys.logger();
my $logger2 = $logsys.logger();


my $catcher = LogCatcher::instance(:!debug);
ok $catcher.subscribe(''), "subscribed ok";
$catcher.set-level-filter :trace;

sleep 1;

$logger.log('nice day');
$logger2.log('a really really nice day', :critical );
dies-ok { $logger.log('another nice day', :warning, :dom2) };

sleep 1;
pass "log catching not tested yet";
$catcher.unsubscribe();

sleep 1;

done-testing;
