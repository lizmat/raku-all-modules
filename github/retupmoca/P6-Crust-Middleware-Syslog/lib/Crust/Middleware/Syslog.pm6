use Crust::Middleware;
use Log::Syslog::Native;

class Crust::Middleware::Syslog is Crust::Middleware { 
    has $.logger;
    method new ($app, :$ident) {
        my %args;
        %args<ident> = $ident if $ident;
        my $logger = Log::Syslog::Native.new(|%args);
        callwith($app, :$logger);
    }
    method CALL-ME(%env) {
        my $logger = $.logger;
        %env<p6sgix.logger> = -> $level, $message {
            my $syslog-level = Log::Syslog::Native::Debug;
            given $level {
                when 'debug'  { $syslog-level = Log::Syslog::Native::Debug;    };
                when 'info'   { $syslog-level = Log::Syslog::Native::Info;     };
                when 'notice' { $syslog-level = Log::Syslog::Native::Notice;   };
                when 'warn'   { $syslog-level = Log::Syslog::Native::Warning;  };
                when 'error'  { $syslog-level = Log::Syslog::Native::Error;    };
                when 'fatal'  { $syslog-level = Log::Syslog::Native::Critical; };
                when 'alert'  { $syslog-level = Log::Syslog::Native::Alert;    };
            }
            $logger.log($syslog-level, $message);
        };
        return $.app()(%env);
    }
}
