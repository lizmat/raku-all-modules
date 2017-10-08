# NAME

Audio::MIDI::Note - playable MIDI note

# DESCRIPTION

This module lets you play notes on a MIDI hardware or software device using
methods that allow to replicate sheet music.

# TABLE OF CONTENTS
- [NAME](#name)
- [DESCRIPTION](#description)
- [NON Perl 6 REQUIREMENTS](#non-perl-6-requirements)
- [SYNOPSIS](#synopsis)
    - [<em>Canon in D</em> by Johann Pachelbel](#canon-in-d-by-johann-pachelbel)
    - [<em>Gorgoroth - A World to Win</em> Solo](#gorgoroth---a-world-to-win-solo)
- [PLAYING TIPS](#playing-tips)
- [ATTRIBUTES](#attributes)
    - [`:stream`](#stream)
    - [`:tempo`](#tempo)
    - [`:value`](#value)
    - [`:velocity`](#velocity)
    - [`:instrument`](#instrument)
    - [`:channel`](#channel)
- [METHODS](#methods)
    - [`.new`](#new)
    - [`.aplay`](#aplay)
    - [`.play`](#play)
        - [First positional](#first-positional)
        - [Second positional](#second-positional)
        - [`:velocity`](#velocity-1)
        - [`:instrument`](#instrument-1)
        - [`:on-on`, `:on`, `:off`](#on-on-on-off)
    - [`.rest`](#rest)
    - [`.riff`](#riff)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# NON Perl 6 REQUIREMENTS

This module uses [Audio::PortMIDI](http://modules.perl6.org/repo/Audio::PortMIDI)
under the hood, which requires [portmidi C library](http://portmedia.sourceforge.net/portmidi/).
On Debian and derivatives, you can install it with `sudo apt-get install libportmidi0`

# SYNOPSIS

## *Canon* by Johann Pachelbel (in C key)

Replication of [this sheet music](http://www.8notes.com/scores/420.asp).
Note: on my system, the midi player on that page kills timidity and I have
to do `sudo service timidity restart` to get my scripts to work again...

```perl6
    use Audio::PortMIDI;
    use Audio::MIDI::Note;

    my $stream = Audio::PortMIDI.new.open-output: 3, 32;
    END { $stream.close }

    my Audio::MIDI::Note $note .= new: :20tempo :$stream, :value(½), :49velocity;

    # Pachelbel `Canon` (in C key)
    # Comments reference this sheet music: http://www.8notes.com/scores/420.asp
    $note   .play(<C4 E4>).play(<G3 D4>)  # first line of bars, with one repeat
            .play(<A3 C4>).play(<E3 B3>)
            .play(<F3 A3>).play(<C3 G3>)
            .play(<F3 A3>).play(<G3 B3>)
    for ^2;

    $note   .play(<C4 G4 E5>).play(<G3 B4 D5>) # second line of bars
            .play(<A3 C5   >).play(<E3 G4 B4>)
            .play(<F3 C4 A4>).play(<C3 E4 G4>)
            .play(<F3 F4 A4>).play(<G3 D4 B4>)

            # first two notes of the chord are half-notes and third one is a crotchet,
            # so we play the half-notes in async with .aplay, and then do
            # the crotchet series with blocking .play
            .velocity(64).value(¼) # play louder and switch to quarter note default
            .aplay(<C4 E4>, ½).play('C5').play('C5')
            .aplay(<G3 D4>, ½).play('D5').play('B4')

            # 10th bar
            .aplay(<A3 C4>, ½).play('C5').play('E5')
            .aplay('E3',    ½).play('G5').play('G4')

            # 11th and 12th bars
            .aplay(<F3 A3>, ½).play('A4').play('F4')
            .aplay('C3'   , ½).play('E4').play('G4')
            .aplay(<F3 A3>, ½).play('F4').play('C5')
            .aplay(<G3 B3>, ½).play('B5').play('G4')

            # 13th bar; after the first chord, we're asked to play louder (velocity)
            .aplay(<C4 E4>, ½).play('C5')
            .velocity(80)
            .play('E5', ⅛).play('G5', ⅛).play('G5', ⅛)
            .play('A5', ⅛).play('G5', ⅛).play('F5', ⅛)

            .aplay(<A3 C4>, ½).play('E5', ¼+⅛).play('E5', ⅛)
            .aplay(<E3 G3>, ½).play('E5',   ⅛).play('F5', ⅛).play('E5', ⅛).play('D5', ⅛)

            # 15th, 16th bar
            .aplay(<F3 A3>, ½).play('C5', ⅛).play('Bb4', ⅛).play('A4', ⅛).play('Bb4', ⅛)
            .aplay(<C3 E3>, ½).play('G4').play('E4')
            .aplay(<F3 A3>, ½).play('C4').play('F4', ⅛).play('E4', ⅛)
            .aplay(<G3 B3>, ½).play('D4').play('G4', ⅛).play('F4', ⅛)

            # 17th bar: we'll sound half-notes in async, and will use .rest
            # to play the quarter-note rest on the treble clef.
            # .rest can take a rest value as argument, but our current value is
            # already a crotchet, so no argument is needed:
            .aplay(<C4 E3>, ½).rest.velocity(64).play('C5')
            .aplay('G3', ½).play('D5').play('B4')

            # Last row of bars
            .aplay(<A3 C4>, ½).play('C5').play('E4')
            .aplay(<E3 B3>, ½).play('G4', ¼+⅛).play('A4', ⅛)
            .aplay(<F3 A3>, ½).play('F4').play('C4')
            .aplay(<C3 G3>, ½).play('E4').play('G4')
            .aplay(<F3 A3>, ½).play('F4').play('E4')
            .aplay(<G3 B3>, ½).play('D4').play('G4')
            .play(<C3 C4 E3>, 1)
    ;
```

## *Gorgoroth - A World to Win* Solo

Part of the solo from [A World to Win](https://www.youtube.com/watch?v=7EvOTkEMlug),
showing swap of instruments, re-use of repeating pieces of music, calculation
of triplet note values, and use of on- and off-beat velocity shortcuts.

```perl6
    use Audio::MIDI::Note;

    my $stream = Audio::PortMIDI.new.open-output: 3, 32;
    END { $stream.close }

    my Audio::MIDI::Note $note .= new: :31tempo :30instrument :$stream :value(⅔ * ⅛);

    # Looping `Gorgoroth - A World to Win` solo with organ chord in the background.
    # We use triplet notes and save repeating pieces into variables for reuse
    my &rhythm = *.play('D#5').play('D5').play('C5');
    my &riff = {
        .aplay(<C4 E4 G4>, 4, :19instrument, :40velocity)

        .play('C5',  ⅔*(¼+⅛) )
        .riff(&rhythm).play('C5',  ⅔*(¼+⅛) )
        .riff(&rhythm).play('G#4', ⅔*(¼+⅛) )
        .riff(&rhythm).play('A#4', ⅔*(¼+⅛) )
        .riff(&rhythm).play('C5',  ⅔*(¼+⅛) )
        .riff(&rhythm).play('C5',  ⅔*(¼+⅛) )
        .riff(&rhythm);
    };

    $note   .riff(&riff)
                .play('G5',  ¼, :on).play('F5',  ¼, :off)
                .play('D#5', ¼     ).play('D5',  ¼, :off)
            .riff(&riff)
                .play('F5',  ¼,:on ).play('D#5', ¼, :off)
                .play('D5',  ¼     ).play('A#4', ¼, :off)
    for ^10;
```

# PLAYING TIPS

* Save repeating chunks into subs and play them with `.riff` method
* Play the piece using the shortest notes and rests it requires, using
`.play`/`.rest` methods. Use the asynchronous `.aplay` method to play
longer notes that overlap these shorter ones.

# ATTRIBUTES

Note: to facilitate chaining, all attributes can be either assigned to directly
or be given the new value as an argument:

```perl6
    $note.value = ½;
    $note.value(½); # same as above; returns invocant
```

#### `:stream`

The `Audio::PortMIDI::Stream` object opened at a MIDI output device. See
[Audio::PortMIDI](http://modules.perl6.org/dist/Audio::PortMIDI) for details.

#### `:tempo`

Positive `Int`.
Specifies the tempo of the piece in beats per minute per **WHOLE** note.
*Defaults to:* `40`

#### `:value`

`Numeric`. Specifies the default value (amount of time it rings) of the played
notes. *Defaults to:* `¼`

#### `:velocity`

`0 <= Int <= 127`. Specifies the default velocity (similar to volume) of the
played notes; `127` indicates as loud as possible.
*Defaults to:* `80` (`mf` loudness in sheet music).

#### `:instrument`

`Int`. [MIDI Patch code](https://www.midi.org/specifications/item/gm-level-1-sound-set)
for the default instrument to use. *Defaults to:* `0` (piano)

#### `:channel`

`Int`. Specifies the MIDI channel to use. *Defaults to:* `0`

# METHODS

## `.new`

```perl6
my Audio::MIDI::Note $note .= new:
    :stream(Audio::PortMIDI.new.open-output: 3, 32)
    :20tempo
    :value(½)
    :49velocity
    :30instrument
    :0channel;
```

Creates and returns a new `Audio::MIDI::Note` object. See [ATTRIBUTES](#ATTRIBUTES)
section for details on the accepted parameters.

## `.aplay`

```perl6
    $note.aplay('C5')
         .aplay(<C4 E4 G4>, ⅛, :on-on, :100velocity, :30instrument);
```

Same as `.play`, but is asynchronous **and returns immediately**.
Useful to play longer notes that overlap shorter ones (that you would play
with `.play`). Takes the same arguments as `.play`

## `.play`

```perl6
    $note.play('C5')
         .play(<C4 E4 G4>, ⅛, :on-on, :100velocity, :30instrument);
```

Plays one or more notes (simultaneously). Takes the following arguments:

#### First positional

An `Str`or a `List` of strings representing the notes to play. Multiple notes
will be played *at the same time*, not consecutively. Valid notes are from
`C0` through `G#10`/`Ab10`. Use hashmark (`#`) to indicate sharps and lower-case B
(`b`) to indicate flats. This argument is case-sensitive.

#### Second positional

Note value for the currently played notes. *Defaults to:* the value of
`:value` attribute.

#### `:velocity`

Note velocity for the currently played notes. *Defaults to:* the value of
`:velocity` attribute.

#### `:instrument`

MIDI patch code for the instrument for the currently played notes.
*Defaults to:* the value of `:instrument` attribute.

#### `:on-on`, `:on`, `:off`

Velocity control shortcuts for on/off beats. `:on-on` is the loudest,
`:on` is less so, but still louder than normal velocity; `:off` is less loud
than normal velocity.

## `.rest`

```perl6
    $note.rest
         .rest(⅛);
```

"Plays" a rest by blocking execution for the specified note value. Takes
`Numeric` note value, which *defaults to:* the value of `:value` attribute.

## `.riff`

```perl6
    my &riff = *.play('C4').play('E4').play('G4');

    $note.&riff;
    $note.riff(&riff);
```

The last two lines in the code above are equivalent. The only issue is you can't
split a method chain that uses `&riff` onto multiple lines. This is where the
`.riff` method comes into play. It takes your `Callable` as an argument and
lets you break up your method chains on multiple lines.

Storing bits of music into variables and then playing them with `.riff` lets
you re-use repeating bars or fragments in a piece of music.

Also worth noting: method chains started on a `WhateverStar` also cannot be
broken up into multiple lines. Just use a set of curlies instead:

```perl6
    my &riff = {
        .play('C4').play('E4')
        .play('G4').play('C5');
    }
```

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Audio-MIDI-Note

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Audio-MIDI-Note/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
