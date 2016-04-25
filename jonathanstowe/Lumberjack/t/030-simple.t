#!perl6

use v6.c;

use Test;

use Lumberjack;

class Foo does Lumberjack::Logger {
}

Foo.log-level = Lumberjack::All;

my $foo = Foo.new;

is $foo.log-level, Lumberjack::All, "we have the 'class' log-level in an instance";

my @messages;
my @filtered-messages;

Lumberjack.all-messages.tap(-> $m { @messages.append: $m });
Lumberjack.trace-messages.act(-> $m { is $m.level, Lumberjack::Trace, "got a trace message" });
Lumberjack.debug-messages.act(-> $m { is $m.level, Lumberjack::Debug, "got a debug message" });
Lumberjack.warn-messages.act(-> $m { is $m.level, Lumberjack::Warn, "got a warn message" });
Lumberjack.info-messages.act(-> $m { is $m.level, Lumberjack::Info, "got an info message" });
Lumberjack.error-messages.act(-> $m { is $m.level, Lumberjack::Error, "got an error message" });
Lumberjack.fatal-messages.act(-> $m { is $m.level, Lumberjack::Fatal, "got a fatal message" });

Lumberjack.filtered-messages.act(-> $m { @filtered-messages.append: $m });

for Lumberjack::Level.enums.values.sort.reverse.map({Lumberjack::Level($_)}) -> $level {
    @messages = ();
    @filtered-messages = ();
    $foo.log-level = $level;
    lives-ok { $foo.log-trace("trace message") }, "send log-trace with level at $level";
    lives-ok { $foo.log-debug("debug message") }, "send log-debug with level at $level";
    lives-ok { $foo.log-info("info message") }, "send log-info with level at $level";
    lives-ok { $foo.log-warn("warning message") }, "send log-warning with level at $level";
    lives-ok { $foo.log-error("error message") }, "send log-error with level at $level";
    lives-ok { $foo.log-fatal("fatal message") }, "send log-fatal with level at $level";
    is @messages.elems, 6, "got six messages to all-messages with level at $level";
    my $expected = $level ~~ Lumberjack::All ?? 6 !! $level.Int;
    is @filtered-messages.elems, $expected , "got the right number of filtered messages ( $expected ) for $level";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
