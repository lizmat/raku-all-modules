[![Build Status](https://travis-ci.org/Garland-g/Cro-H.svg?branch=master)](https://travis-ci.org/Garland-g/Cro-H)

NAME
====

Cro::H - A low-level component to interconnect two Cro pipelines

SYNOPSIS
========

    #These classes are stubbed
    use Cro::H;
    my $h-pipe = Cro::H.new;

    my $pipeline1 = Cro.compose(Cro::Source, $h-pipe, Cro::Sink)
    my $pipeline2 = Cro.compose(Cro::Source, $h-pipe, Cro::Sink)

    ($pipeline1, $pipeline2)>>.start;
    #Both sinks will receive all the values from both sources

DESCRIPTION
===========

Cro::H is a way to interconnect two pipelines without needing to terminate either pipeline.

Split off a second pipelines by creating a source that outputs nothing as the start of the second pipeline.

Merge two pipelines by creating a sink that ignores all incoming values as the end of the second pipeline.

    Sample pipeline:
     ---------      _________________      -------
    | Source1 | -> |______     ______| -> | Sink1 |
     ---------            |   |           -------
                          | H |
     ---------      ______|   |______      -------
    | Source2 | -> |_________________| -> | Sink2 |
     ---------                             -------

AUTHOR
======

Travis Gibson <TGib.Travis@protonmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

