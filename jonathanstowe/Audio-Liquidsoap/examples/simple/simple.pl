#!/usr/bin/env perl6 

use v6.c;

use Audio::Liquidsoap;

multi sub MAIN(Str :$host = 'localhost', Int :$port = 1234, Str :$path = '/tmp/incoming' ) {
    CATCH {
        when X::NoServer {
            say "Cannot connect on $host:$port, please check that 'liquidsoap' is running";
            exit;
        }
    }

    my $soap = Audio::Liquidsoap.new(:$host, :$port);
    say "Using liquidsoap version { $soap.version } up since { DateTime.new(now - $soap.uptime) }";

    react {
        whenever IO::Notification.watch-path($path).grep({ $_.path ~~ /\.mp3$/ }).unique(as => { $_.path }, expires => 5) -> $path {
            CATCH {
                when X::Command {
                    say "Couldn't add '{ $path.path }' : { $_.error }";
                }
            }
            say "Adding { $path.path } to the player";
            my $rid = $soap.queues<incoming>.push: $path.path;
            for $soap.requests.trace($rid) -> $trace {
                say "[{ $trace.when.Str }] : { $trace.what }";
            } 
        }
        whenever Supply.interval(60) {
            sub get-meta-str($meta) returns Str {
                my $str = "On Air now [since { $meta.on-air.Str }] :  ";
                if $meta.artist.defined && $meta.title.defined {
                    $str ~= "{ $meta.artist } - { $meta.title }";
                }
                else {
                    $str ~= $meta.filename;
                }
                $str;
            }
            # This makes the assumption that the 0 is our 'bedding'
            my $on-rid = $soap.requests.on-air.grep({ $_ != 0 })[0];
            if $on-rid.defined {
                my $meta = $soap.requests.metadata($on-rid);
                if $meta.status.defined {
                    say get-meta-str($meta);
                }
            }
        }
    }
}



# vim: expandtab shiftwidth=4 ft=perl6
