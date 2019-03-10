use v6;

use Smack::Middleware;

unit class Smack::Middleware::AccessLog is Smack::Middleware;

use Smack::Util;
use Apache::LogFormat::Compiler;

has &.logger;
has Str $.format = 'combined';
has $!compiled-format;

has %.block-handlers;
has %.char-handlers;

my constant %formats = {
    common   => '%h %l %u %t "%r" %>s %b',
    combined => '%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-agent}i"',
};

method configure(%env) {
    my $fmt = $.format // 'combined';
       $fmt = %formats{ $fmt } if %formats{ $fmt }:exists;

    $!compiled-format = Apache::LogFormat::Compiler.new.compile($fmt,
        %.block-handlers, %.char-handlers);

    &!logger //= -> $line {
        %env<p6w.errors>.emit: $line;
    };

    callsame();
}

method call(%env) {
    callsame() then-with-response -> $status, @headers, $entity {
        my Promise $content-length-promise .= new;

        $content-length-promise.then({
            my $content-length = .result;

            my $log-line = self.log-line($status, @headers, %env, :$content-length);
            &.logger.($log-line);

            CATCH {
                default { &.logger.($_) }
            }
        });

        content-length(%env, $entity, $content-length-promise, :defer);
    }
}

method log-line(Int() $status, @headers, %env, :$content-length, :$req-time, DateTime :$time = DateTime.now) {
    $!compiled-format.format(
        %env,
        [ $status, @headers ],
        $content-length,
        $req-time,
        $time,
    ).chomp;
}
