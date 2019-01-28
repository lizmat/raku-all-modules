use v6.c;
unit module Reaper::Control:ver<0.0.2>;

=begin pod

=head1 NAME

Reaper::Control - An OSC controller interface for Reaper

=head1 SYNOPSIS

  use Reaper::Control;

  # Start listening for UDP messages from sent from Reaper.
  my $listener = reaper-listener(:host<127.0.0.1>, :port(9000));

  # Respond to events from Reaper:
  react whenever $listener.reaper-events {
      when Reaper::Control::Event::Play {
          put 'Playing'
      }
      when Reaper::Control::Event::Stop {
          put 'stopped'
      }
      when Reaper::Control::Event::PlayTime {
          put "seconds: { .seconds }\nsamples: { .samples }\nbeats: { .beats }"
      }
      when Reaper::Control::Event::Mixer {
          put "levels: ", join ',', .master.vu, .tracks.map( *.vu ).Slip
      }
      when Reaper::Control::Event::Unhandled {
          .perl.say
      }
  }
=head1 DESCRIPTION

Reaper::Control is an L<OSC controller interface|https://www.reaper.fm/sdk/osc/osc.php> for L<Reaper|https://www.reaper.fm>, a digital audio workstation.
Current features are limited and relate to listening for play/stop, playback position and mixer levels but there is a lot more which can be added in the future.

To start listening call the C<reaper-listener> subroutine, you can then obtain a C<Supply> of events from the listener's C<.reaper-events> method.
All events emitted from the supply are subclasses of the C<Reaper::Control::Event> role. Messages not handled by the default message handler are emitted as C<Reaper::Control::Unhandled> objects, their contents can be accessed in the message attribute.

To skip the default message handler you may instead tap the lister's C<.reaper-raw> method. This supply emits C<Net::OSC::Bundle> objects, see the Net::OSC module for more on this object.

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

our class Event {
    #= Base class for all reaper events.
    #= No functionality here, just an empty class.
}

our class Event::PlayState is Event {
    #= An abstract class defining the methods of Play and Stop classes.
    #= Use this type if you need to accept either Play or Stop objects.

    method is-playing( --> Bool) { … };

    method is-stopped( --> Bool) { … };
}

our class Event::Play is Event::PlayState {
    #= The Play version of the PlayState role.
    #= This object is emitted when playback is started.

    method is-playing( --> Bool) {
        #= Returns True
        True
    };

    method is-stopped( --> Bool) {
        #= Returns False
        False
    };
}

our class Event::Stop is Event::PlayState {
    #= The Stop version of the PlayState role.
    #= This object is emitted when playback is stopped.

    method is-playing( --> Bool) {
        #= Returns False
        False
    };

    method is-stopped( --> Bool) {
        #= Returns True
        True
    };
}

our class Event::PlayTime is Event {
    #= This message bundles up elapsed seconds, elapsed samples and a string of the current beat position.
    #=
    has Numeric $.seconds;
    has Numeric $.samples;
    has Str $.beats;
}

#! holds values for a Mixer
our class Event::Level is Event {
    #= This message bundles up audio levels from the mixer.
    #=
    has Rat $.vu is rw;
    has Rat $.vu-l is rw;
    has Rat $.vu-r is rw;
}

#! Holds levels for tracks and master
our class Event::Mixer is Event {
    #= This message bundles up audio level information from the mixer.
    #= Master level is held in the master attribute and tracks are stored in the tracks attribute.
    has Event::Level $.master = Event::Level.new;
    has Event::Level @.tracks;

    #! Ensure there are no luring undefined values from a missing message
    method audit {
        for @!tracks {
            $_ .= new unless .defined
        }
        self
    }
}

#! Holds unhandled messages
our class Event::Unhandled is Event {
    #= A generic wrapper for messages not handled by the core interface
    has %.messages
}

#! A listener which wraps up the parsing logic to handle events from Reaper
our class Listener {
    #= This class bundles up a series of tapped supplies which define a listener workflow.
    #= To construct a new listener call the listener-udp method to initialise a UDP listener workflow.

    use Net::OSC::Bundle;
    use Net::OSC::Message;

    has Supplier            $!bundles = Supplier.new;
    has Supplier            $!reaper  = Supplier.new;
    has IO::Socket::Async   $!listener;
    has Tap                 $!unbundler;
    has Tap                 $!message-mapper;

    #! Processed event stream
    method reaper-events( --> Supply) {
        $!reaper.Supply
    }

    #! Raw OSC bundle stream
    method reaper-raw( --> Supply) {
        $!bundles.Supply
    }

    #! Setup a pipeline decoding from a UDP socket
    method listen-udp(Str :$host, Int :$port) {
        $!listener.close if defined $!listener;
        $!listener .= bind-udp($host, $port);
        self.init-unbundle;
        self.init-message-mapper;

        self
    }

    #! Initialise an OSC bundler parser on the current pipeline
    method init-unbundle( --> Tap) {
        $!unbundler.close if defined $!unbundler;
        $!unbundler = $!listener.Supply(:bin).grep( *.elems > 0 ).tap: -> $buf {
            try {
                CATCH { warn "Error unpacking OSC packet:\n{ .gist }" }
                $!bundles.emit: Net::OSC::Bundle.unpackage($buf) if $buf[0] == 0x23; # eg does it start with '#' (a bundle)
                $!bundles.emit: Net::OSC::Bundle.new( :messages(Net::OSC::Message.unpackage($buf)) ) if $buf[0] == 0x2F; # eg does it start with '/' (a message)
            }
        }
    }

    #! Initialise an OSC Message mapper on the current pipeline
    method init-message-mapper( --> Tap) {
        $!message-mapper.close if defined $!message-mapper;

        # Instantiate immutable objects
        my $play = Event::Play.new;
        my $stop = Event::Stop.new;

        $!message-mapper = $!bundles.Supply.tap: {
            my Bool             $is-playing;
            my Numeric          $seconds;
            my Numeric          $samples;
            my Str              $beats;
            my Event::Mixer     $mixer;
            my Event::Unhandled $unhandled;

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
                # VU level messages
                when .path ~~ / '/' $<track> = [<alnum>+] $<channel> = ['/'? \d*] '/vu' $<lr> = ['/L'|'/R'?]/ {
                    $mixer .= new unless $mixer.defined;
                    my Event::Level $topic = do
                        if ~$<track> eq 'master' {
                            $mixer.master
                        }
                        else {
                            # assuming track
                            my $index = do
                                with ~$<channel> -> $c {
                                    try {
                                            CATCH {warn "Error converting channel number $c to Int"; next}
                                        $c.substr(1).Int if $c.chars > 0
                                    }
                                }
                                else {
                                    0
                                }
                            $mixer.tracks[$index] .= new if !$mixer.tracks or $mixer.tracks.end < $index or !$mixer.tracks[$index].defined;

                            $mixer.tracks[$index]
                        }

                    given ~$<lr> -> $channel {
                        when $channel ~~ '/L' {
                            $topic.vu-l = .args[0]
                        }
                        when $channel ~~ '/R' {
                            $topic.vu-r = .args[0]
                        }
                        default {
                            $topic.vu = .args[0]
                        }
                    }
                }
                default {
                    # Rebundle unhandled messages and pass them on
                    $unhandled .= new unless $unhandled.defined;
                    $unhandled.messages{.path} = .args
                }
            }

            $!reaper.emit: $is-playing ?? $play !! $stop if defined $is-playing;
            $!reaper.emit: Event::PlayTime.new(:$seconds :$samples :$beats) if $seconds and $samples and $beats;
            $!reaper.emit: $mixer.audit if $mixer.defined;
            $!reaper.emit: $unhandled if $unhandled.defined;
        }
    }
}

#! Create a listener
our sub reaper-listener(Str :$host, Int :$port, Str :$protocol = 'UDP' --> Listener) is export {
    #= Create a Listener object which encapsulates message parsing and event parsing.
    #= The protocol argument currently only accepts UDP.
    #= Use the reaper-events method to obtain a Supply of events received, by the Listener, from Reaper.

    given $protocol {
        when 'UDP' {
            Listener.new.listen-udp(:$host, :$port)
        }
        default {
            die "Unhandled protocol: '$protocol'"
        }
    }
}
