#!/usr/bin/env perl6

unit module Log::ZMQ::Common;

use v6;

our %PROTOCOL is export = ('prefix' => -4
                          , 'domain' => -3
                          , 'level' => -2
                          , 'format' => -1
                          , 'content' => 1
                          , 'timestamp' => 2);

our %LEVELS is export = ( :critical(0) :error(1) :warning(2) :info(3) :debug(4) :trace(5) );
our %ILVELS is export = zip(%LEVELS.values, %LEVELS.keys).flat;

constant $log-uri is export = "tcp://127.0.0.1:3999";

