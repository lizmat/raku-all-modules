[![Build Status](https://travis-ci.org/samgwise/Reaper-control.svg?branch=master)](https://travis-ci.org/samgwise/Reaper-control)

NAME
====

Reaper::Control - An OSC controller interface for Reaper

SYNOPSIS
========

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

DESCRIPTION
===========

Reaper::Control is an [OSC controller interface](https://www.reaper.fm/sdk/osc/osc.php) for [Reaper](https://www.reaper.fm), a digital audio workstation. Current features are limited and relate to listening for play/stop, playback position and mixer levels but there is a lot more which can be added in the future.

To start listening call the `reaper-listener` subroutine, you can then obtain a `Supply` of events from the listener's `.reaper-events` method. All events emitted from the supply are subclasses of the `Reaper::Control::Event` role. Messages not handled by the default message handler are emitted as `Reaper::Control::Unhandled` objects, their contents can be accessed in the message attribute.

To skip the default message handler you may instead tap the lister's `.reaper-raw` method. This supply emits `Net::OSC::Bundle` objects, see the Net::OSC module for more on this object.

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### sub reaper-listener

```perl6
sub reaper-listener(
    Str :$host,
    Int :$port,
    Str :$protocol = "UDP"
) returns Reaper::Control::Listener
```

Create a Listener object which encapsulates message parsing and event parsing. The protocol argument currently only accepts UDP. Use the reaper-events method to obtain a Supply of events received, by the Listener, from Reaper.

### Reaper::Control::Event
Base class for all reaper events. No functionality here, just an empty class.

### Reaper::Control::Event::PlayState
An abstract class defining the methods of Play and Stop classes. Use this type if you need to accept either Play or Stop objects.

### Reaper::Control::Event::Play
The Play version of the PlayState role. This object is emitted when playback is started.

### Reaper::Control::Event::Stop
The Stop version of the PlayState role. This object is emitted when playback is stopped.

### Reaper::Control::Event::PlayTime
This message bundles up elapsed seconds, elapsed samples and a string of the current beat position.

### Reaper::Control::Event::Level
This message bundles up audio levels from the mixer.

### Reaper::Control::Event::Mixer
This message bundles up audio level information from the mixer. Master level is held in the master attribute and tracks are stored in the tracks attribute.

### Reaper::Control::Event::Unhandled
A generic wrapper for messages not handled by the core interface

### Reaper::Control::Listener
This class bundles up a series of tapped supplies which define a listener workflow. To construct a new listener call the listener-udp method to initialise a UDP listener workflow.

