use v6.c;

use PSGI;
use FastCGI::NativeCall;

class FastCGI::NativeCall::PSGI {
    has FastCGI::NativeCall $.fcgi;
    has $!body;
    has %!env;
    has Callable $.app;

    proto method new(|c) { * }

    multi method new(FastCGI::NativeCall $fcgi) {
        DEPRECATED('named parameter "fcgi"');
        self.bless(:$fcgi);
    }

    multi method new(FastCGI::NativeCall :$fcgi!) {
        self.bless(:$fcgi);
    }

    multi method new(Str :$path!, Int :$backlog = 16) {
        my $fcgi = FastCGI::NativeCall.new(:$path, :$backlog);
        self.bless(:$fcgi);
    }

    multi method new(Int :$sock!) {
        my $fcgi = FastCGI::NativeCall.new(:$sock);
        self.bless(:$fcgi);
    }

    multi method run(&app) {
        $!app = &app;
        self.run;
    }

    multi method run {
        while $.fcgi.accept {
            %!env = $.fcgi.env;
            if %!env<CONTENT_LENGTH> {
                $!body = $.fcgi.Read(%!env<CONTENT_LENGTH>.Int).encode;
            }
            my $res = self.handler;
            $.fcgi.Print($res);
        }
    }

    proto method app(|c) { * }

    multi method app(Callable $app --> Callable) {
        $!app = $app;
    }

    multi method app(--> Callable) is rw {
        $!app;
    }

    method handler {
        %!env<psgi.version>            = [1,0];
        %!env<psgi.url_scheme>        = 'http';
        %!env<psgi.multithread>     = False;
        %!env<psgi.multiprocess>     = False;
        %!env<psgi.input>            = $!body;
        %!env<psgi.errors>            = $*ERR;
        %!env<psgi.run_once>        = False;
        %!env<psgi.nonblocking>        = False;
        %!env<psgi.streaming>        = False;

        my $result;
        if $!app ~~ Callable {
            $result = $!app(%!env);
        }
        elsif $!app.can('handle') {
            $result = $!app.handle(%!env);
        }
        else {
            die "invalid application";
        }
        my $output = encode-psgi-response($result);
        return $output;
    }
}

# vim: ft=perl6
