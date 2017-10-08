#!perl6

use v6;

use Test;
use Lumberjack;

my $file = $*CWD.child('test-log');

END {
    $file.unlink;
}

Lumberjack.dispatchers.append: Lumberjack::Dispatcher::File.new(file => $file.Str);

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


my $fh = $file.open(:r);

my $content = $fh.slurp-rest;

like $content, /'[Trace] Banana do-trace : trace message'/, "got expected text for trace";
like $content, /'[Debug] Banana do-debug : debug message'/, "got expected text for debug";
like $content, /'[Info] Banana do-info : info message'/, "got expected text for info";
like $content, /'[Warn] Banana do-warn : warn message'/, "got expected text for warn";
like $content, /'[Error] Banana do-error : error message'/, "got expected text for error";
like $content, /'[Fatal] Banana do-fatal : fatal message'/, "got expected text for fatal";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
