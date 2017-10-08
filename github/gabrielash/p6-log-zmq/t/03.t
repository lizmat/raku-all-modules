#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say "testing Logger README ";

use Net::ZMQ::Context:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');

use Log::ZMQ::Logger;

if 1 {

my $l = Logging::instance( 'example' ).logger;
$l.log( 'an important message');

} else {
my $logger = Logging::instance('example' ,'tcp://127.0.0.1:3301'
                                , :default-level( :warning )
                                , :domain-list( < database engine front-end nativecall > )
                                , :format( :json ))\
                              .logger;

$logger.log( 'a very important message', :critical, :front-end );

my $db-logger = Logging::instance.logger.domain( :database );
$db-logger.log( 'meh');

}

done-testing;
