#!/usr/bin/env perl -w

use strict;
use Test;
use Cache::Memcached;
#use IO::Socket::INET;

my @misc_stats_keys = qw/ bytes bytes_read bytes_written
                          cmd_get cmd_set connection_structures curr_items
                          get_hits get_misses
                          total_connections total_items/;

plan 16 + @misc_stats_keys.elems;

my $testaddr = "127.0.0.1:11211";
my $port = 11211;

try {
   my $msock = IO::Socket::INET.new(host => $testaddr, port => $port);
   CATCH {
      default {
         skip-rest "No memcached instance running at $testaddr";
         exit 0;
      }
   }
}

my $memd = Cache::Memcached.new(
    servers   => [ $testaddr ],
    namespace => "Cache::Memcached::t/$*PID/" ~ (now % 100) ~ "/",
);

my $misc_stats = $memd.stats('misc');
ok($misc_stats, 'got misc stats');

isa-ok($misc_stats, Hash, 'misc stats');
isa-ok($misc_stats{'total'}, Hash, 'misc stats total');
isa-ok($misc_stats{'hosts'}, Hash, 'misc stats hosts');
isa-ok($misc_stats{'hosts'}{$testaddr}, Hash,
       "misc stats hosts $testaddr");

for @misc_stats_keys -> $stat_key  {
    ok($misc_stats{'total'}{$stat_key}:exists,
       "misc stats total contains $stat_key");
    ok($misc_stats{'hosts'}{$testaddr}{'misc'}{$stat_key}:exists,
       "misc stats hosts $testaddr misc contains $stat_key");
}

done-testing();
