#! /usr/bin/env perl6
use v6;

class ReaperEvent { }

class ReaperEvent::PlayState is ReaperEvent {
    method is-playing( --> Bool) { … };

    method is-stopped( --> Bool) { … };
}

class ReaperEvent::Play is ReaperEvent::PlayState {
    method is-playing( --> Bool) { True };

    method is-stopped( --> Bool) { False };
}

class ReaperEvent::Stop is ReaperEvent::PlayState {
    method is-playing( --> Bool) { False };

    method is-stopped( --> Bool) { True };
}


class ReaperEvent::PlayTime is ReaperEvent {
    has Numeric $.seconds;
    has Numeric $.samples;
    has Str $.beats;
}

sub MAIN(Str :$host = '127.0.0.1', Int :$port = 9000) {
    use Net::OSC;
    use Net::OSC::Bundle;

    my IO::Socket::Async $udp-listener .= bind-udp($host, $port);

    my Supplier $bundles .= new;
    my $listener = $udp-listener.Supply(:bin).grep( *.elems > 0 ).tap: -> $buf {
        try {
            CATCH { warn "Error unpacking OSC bundle:\n{ .gist }" }
            $bundles.emit: Net::OSC::Bundle.unpackage($buf)
        }
    }

    my Supplier $reaper .= new;

    $reaper.Supply.tap( *.gist.say );

    # Instatiate imutable objects
    my $play = ReaperEvent::Play.new;
    my $stop = ReaperEvent::Stop.new;

    react whenever $bundles.Supply {
        my Bool $is-playing;
        my Numeric $seconds;
        my Numeric $samples;
        my Str      $beats;

        for .messages {
            when .path eq '/time' {
                $seconds = .args.head
            }
            when .path eq '/samples' {
                $samples = .args.head
            }
            when .path eq '/beat/str' {
                $beats = .args.head
            }
            when .path eq '/play' {
                $is-playing = (.args.head == 1) ?? True !! False
            }
            when .path eq '/stop' {
                $is-playing = (.args.head == 0) ?? True !! False
            }
            when .path ~~ / '/str' $/ {
                #ignore strings for now
            }
            default { warn "Unhandled message: { .gist }" }
        }

        $reaper.emit: $is-playing ?? $play !! $stop if defined $is-playing;
        $reaper.emit: ReaperEvent::PlayTime.new(:$seconds :$samples :$beats) if $seconds and $samples and $beats;
    }
}
