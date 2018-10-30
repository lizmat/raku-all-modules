#!perl6

use v6;

use Test;

use Lumberjack;

isa-ok Lumberjack.all-messages, Supply, "all-messages is a Supply";

is Lumberjack.default-level, Lumberjack::Error, "got the right default level";

class FooLogger does Lumberjack::Dispatcher {
    has @.messages;
    method log(Lumberjack::Message $message) {
        @!messages.append: $message;
    }
}

my $dispatcher = FooLogger.new;

Lumberjack.dispatchers.append: $dispatcher;

my @messages;
my @filtered-messages;

Lumberjack.all-messages.act({ @messages.append: $_ });
Lumberjack.filtered-messages.act({ @filtered-messages.append: $_ });

my $message;

throws-like { Lumberjack::Message.new }, X::AdHoc, "message with message";

lives-ok { $message = Lumberjack::Message.new(message => 'test message') }, "create test message";


is $message.level, Lumberjack.default-level, "and it got the default level";
ok $message ~~ Lumberjack.default-level, "and the smart match works";

lives-ok { Lumberjack.log($message) }, "send empty message";

is @messages.elems, 1, "got one message total";
is @filtered-messages.elems, 1, "got one in filtered because we used the defaults";

$message = Lumberjack::Message.new(message => "test message 2", level => Lumberjack::Debug);
lives-ok { Lumberjack.log($message) }, "send message with level set";

is @messages.elems, 2, "now have two messages total";
is @filtered-messages.elems, 1, "but still got one in filtered because higher level than the default";
is $dispatcher.messages.elems, @filtered-messages.elems, "and our dispatcher saw the right number too";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
