#!perl6

use v6;

use Test;
use Lumberjack;
use Lumberjack::Message::JSON;

my $message = Lumberjack::Message.new(message => 'test message');

lives-ok { $message does Lumberjack::Message::JSON }, "mixin role into message";

does-ok $message,  Lumberjack::Message::JSON, "and not unexpectedly it has the role";

my $out;

lives-ok { $out = $message.to-json }, "to-json";

my $new-mess;

lives-ok { $new-mess = ( Lumberjack::Message but  Lumberjack::Message::JSON).from-json($out) }, "create from JSON with mixin";
does-ok $new-mess,  Lumberjack::Message::JSON, "and not unexpectedly it has the role";
isa-ok $new-mess, Lumberjack::Message, "and a message too";

is $new-mess.message, $message.message, "and the message got round-tripped properly";
is $new-mess.level, $message.level, "and they have the same level";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
