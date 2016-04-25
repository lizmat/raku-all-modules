#!perl6

use v6;

use Test;
use Lumberjack;
use Lumberjack::Dispatcher::Supply;

class Foo does Lumberjack::Logger {
}

my $s;

Foo.log-level = Lumberjack::All;

lives-ok { $s = Lumberjack::Dispatcher::Supply.new }, "create the dispatcher";

lives-ok { Lumberjack.dispatchers.append: $s }, "add our dispatcher";

my @messages;

lives-ok { $s.tap(-> $m { @messages.push: $m }) }, "tap via the delegate";

Foo.new.log-debug("test-message");

is @messages.elems, 1, "got the message via tap";
isa-ok @messages[0], Lumberjack::Message, "and it's a message";




done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
