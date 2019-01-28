#! /usr/bin/env perl6
use v6.c;
use Reaper::Control;

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
