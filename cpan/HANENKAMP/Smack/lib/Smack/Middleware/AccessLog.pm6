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
    combined => '%h %l %u %t "%r" %>2 %b "${Referer}i" "%{User-agent}i"',
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
        my $cl = content-length(%env, $entity).Promise;
        start {
            my $content-length = await $cl;
            CATCH {
                default { &.logger.($_) }
            }
            my $log-line = self.log-line($status, @headers, %env, :$content-length);
            &.logger.($log-line);
        }

        Nil
    }
}

method log-line(Int() $status, @headers, %env, :$content-length, :$req-time, DateTime :$time = DateTime.now) {
    $!compiled-format.format(
        %env,
        [ $status, @headers ],
        $content-length,
        $req-time,
        $time,
    );
}
