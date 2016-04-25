#!perl6

use v6;

use Test;

use Lumberjack;

class Client does Lumberjack::Logger {
}

class Dispatcher does Lumberjack::Dispatcher {
    has Lumberjack::Message @.messages;
    method log(Lumberjack::Message $message) {
        @!messages.append: $message;
    }
}

Client.log-level = Lumberjack::All;

my Dispatcher %dispatchers{Lumberjack::Level};

for Lumberjack::Level.enums.values.sort.reverse.map({Lumberjack::Level($_)}) -> $level {
    my $dispatcher = Dispatcher.new(levels => $level);
    Lumberjack.dispatchers.append: $dispatcher;
    %dispatchers{$level} = $dispatcher;
}

my $foo = Client.new;

lives-ok { $foo.log-trace("trace message") }, "send log-trace";
lives-ok { $foo.log-debug("debug message") }, "send log-debug";
lives-ok { $foo.log-info("info message") }, "send log-info";
lives-ok { $foo.log-warn("warning message") }, "send log-warning";
lives-ok { $foo.log-error("error message") }, "send log-error";
lives-ok { $foo.log-fatal("fatal message") }, "send log-fatal";

for %dispatchers.values -> $dispatcher {
    if $dispatcher.levels !~~ Lumberjack::All|Lumberjack::Off {
        is $dispatcher.messages.elems, 1, "and dispatcher with level { $dispatcher.levels } has 1";
    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
