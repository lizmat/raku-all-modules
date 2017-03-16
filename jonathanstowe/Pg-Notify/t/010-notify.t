#!/usr/bin/env perl6

use v6.c;

use Test;

use Pg::Notify;
use DBIish;
need  DBDish::Pg::Native;

my %args;
%args<database> = %*ENV<PG_NOTIFY_DB> // 'dbdishtest';


if %*ENV<PG_NOTIFY_USER> -> $user {
    %args<user> = $user;
}
if %*ENV<PG_NOTIFY_PW> -> $pw {
    %args<password> = $pw;
}

my $db = DBIish.connect('Pg', |%args);
my $channel = "test";

my $notify = Pg::Notify.new(:$db, :$channel );

my $supply;


lives-ok { $supply = $notify.Supply }, "get the supply";
isa-ok $supply, Supply, "and it is a supply";

my $test-promise = Promise.new;

my $value;

$supply.act(-> $v { $value = $v; $test-promise.keep: True });

$db.do("NOTIFY $channel, 'TEST VALUE'");
await Promise.anyof($test-promise, Promise.in(1));
isa-ok $value, DBDish::Pg::Native::pg-notify;
is $value.extra, 'TEST VALUE', "got the right value";
is $value.relname, "test", "and got the right relname";

$value = Any;
$test-promise = Promise.new;
$db.do("NOTIFY othername, 'TEST VALUE'");
await Promise.anyof($test-promise, Promise.in(1));
ok $test-promise.status ~~ Planned, "notify didn't fire with a different channel";

lives-ok { $notify.unlisten }, "unlisten";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
