#!perl6

use v6;

use Test;
use Lumberjack :FORMAT;

class Banana::Gorilla does Lumberjack::Logger {
}
my $message = Lumberjack::Message.new(message => "test message", class => Banana::Gorilla, level => Lumberjack::Fatal);

is format-message("[%P]", $message),"[{ $*PID }]", '%P works';
is format-message("[%N]", $message),"[{ $*PROGRAM-NAME }]", '%N works';
is format-message("[%C]", $message),"[Banana::Gorilla]", "%C works";
is format-message("[%L]", $message),"[Fatal]", "%L works";
is format-message("[%M]", $message), "[test message]", "%M works";
is format-message("[%D]", $message),"[{ DateTime::Format::RFC2822.new.to-string($message.when)}]", "%D works";
is format-message("[%S]", $message), '[<unit>]', '%S works for unit case';
is format-message("[%F]", $message), '[t/050-formatter.t]', '%F works';
is format-message("[%l]", $message), '[10]', '%l works';



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
