#!perl6

use v6.c;
use Test;

use MQ::Posix;


my $name = ('a' .. 'z').pick(8).join('') ~ $*PID.Str;

my $reader;
lives-ok { $reader = MQ::Posix.new(:$name, :r, :create ) }, "new reader";

my $writer;
lives-ok { $writer = MQ::Posix.new(:$name, :w, :create ) }, "new writer";

await $writer.send("test message");

react {
    whenever $reader.Supply -> $v {
        is $v.decode, "test message", "got the message";
        lives-ok { $reader.close }, "close reader";
        lives-ok { $reader.unlink; } , "unlink";
        lives-ok { $writer.close }, "close writer";
        done;
    }
}



done-testing;
# vim: ft=perl6 ts=4 sw=4 expandtab
