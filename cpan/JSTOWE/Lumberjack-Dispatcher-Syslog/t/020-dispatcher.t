#!perl6

use v6;

use Test;
use Lumberjack;
use Lumberjack::Dispatcher::Syslog;


Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Syslog.new;

class Banana does Lumberjack::Logger {
    method do-debug() {
        self.log-debug("debug message");
    }
    method do-trace() {
        self.log-trace("trace message");
    }
    method do-info() {
        self.log-info("info message");
    }
    method do-warn() {
        self.log-warn("warn message");
    }
    method do-error() {
        self.log-error("error message");
    }
    method do-fatal() {
        self.log-fatal("fatal message");
    }
}

Banana.log-level = Lumberjack::All;

my $banana = Banana.new;

lives-ok { $banana.do-trace }, "trace";


lives-ok { $banana.do-debug }, "debug";


lives-ok { $banana.do-info }, "info";


lives-ok { $banana.do-warn }, "warn";


lives-ok { $banana.do-error }, "error";


lives-ok { $banana.do-fatal }, "fatal";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
