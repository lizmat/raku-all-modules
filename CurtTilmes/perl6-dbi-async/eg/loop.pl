#!/usr/bin/env perl6

use DBI::Async;

my $db = DBI::Async.new('Pg', connections => 1);

loop {
    try {
        say $db.query("select version()").array[0];
        CATCH {
            default {
                $*ERR.print: $_;
            }
        }
    }
    sleep 1;
}

