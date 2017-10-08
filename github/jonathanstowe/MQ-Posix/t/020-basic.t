#!perl6

use v6.c;
use Test;

use MQ::Posix;

my $obj;

my $name = ('a' .. 'z').pick(8).join('') ~ $*PID.Str;

lives-ok { $obj = MQ::Posix.new(:$name, :r, :w, :create, max-messages => 10, message-size => 4096) }, "new";

isa-ok $obj, MQ::Posix;

my $attrs;

lives-ok { $attrs = $obj.attributes }, "get attributes";
isa-ok $attrs, 'MQ::Posix::Attr';

is $attrs.max-messages, 10 ,  "got maxmsg";
is $attrs.message-size, 4096, "got msgsize";

lives-ok { $obj.close }, "close";
lives-ok { $obj.unlink } , "unlink";

done-testing;
# vim: ft=perl6 ts=4 sw=4 expandtab
