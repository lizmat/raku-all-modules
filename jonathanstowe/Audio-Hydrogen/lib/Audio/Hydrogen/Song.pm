use v6;

=begin pod

=head1 NAME

Audio::Hydrogen::Song - description of a song

=head1 DESCRIPTION

The song file is a standalone file with the extension C<.h2song> which
contains the descriptions of the patterns and instruments that make up
a "song" in Hydrogen. There can be any number of patterns and these can
be arranged in groups as pattern sequences.  The instruments can either
be copied from a drumkit or can be created afresh as required.

For a song file to be usable in Hydrogen it needs only at least one pattern
and any instruments that may be used, the application will supply its own
defaults if needed.

=head1 METHODS

=head2 attribute version

This is L<Version> object that represents the version of Hydrogen that created
the song file. This defaults to "0.9.5" which is the version I tested with, but
it may have some impact on the way some values are interpreted.

=head2 attribute bpm

This is the BPM as an integer, it defaults to 120.

=head2 attribute volume

This is the global volume as a Rat, it defaults to 1.0


=head2 attribute metronome-volume

This is the volume of the built in metronome, it defaults
to 0.0


=head2 attribute name

This is the user visible name of the song, it can be left blank.

=head2 attribute author

This is some text describing the author of the song, it may be blank.

=head2 attribute notes

Some free text notes regarding the song, it may be blank.

=head2 attribute license

Some license text.  It may be blank.

=head2 attribute loop-enabled

A Bool which is by default not set, it appears that Hydrogen itself
defaults to True though.

=head2 attribute mode

This is a string which may be "pattern" or "song" to determine the
playback mode of Hydrogen, the default is "pattern".

=head2 attribute humanize-time

This is a Rat in the range 0 .. 1.0 that determines the extent to
which a small random change is applied to the timing of notes. By
default it isn't set which means time isn't "humanized".

=head2 attribute humanize-velocity

This is a Rat in the range 0 .. 1.0 that determines the extent to
which a small random change is applied to the velocity of notes.
By default it isn't set which means velocity isn't "humanized".

=head2 attribute swing-factor

This is a factor that adjusts the probability that the timing
of a note will be altered by some amount. I'm not quite sure
of the algorithm used. By default it isn't set which means there
is no "swing".  A good description of the notion of "swing" in
terms of electronic sequencers can be found in this interview
with Roger Linn who largely invented the idea:

https://www.attackmagazine.com/features/interview/roger-linn-swing-groove-magic-mpc-timing/

=head2 attribute patterns

This is a list of L<Audio::Hydrogen::Pattern> objects. There should be at least one and they
should all have a unique name.

=head2 attribute instruments

This is a list of L<Audio::Hydrogen::Instrument> objects.  The id attributes of the instruments
should be unique and should be those referenced by the patterns.  The sample filenames (either
single or those in layers,) should be absolute paths (unlike those in drumkits that may be
relative to the drumkit directory.)

=head2 attribute pattern-sequence

This is an ordered list of PatternGroup objects, which in turn contains a on ordered list of
C<pattern-id> Strs which refer to the patterns in the group.

=head2 attribute plugins

This is a list of Plugin objects that describe the LADSPA plugins that are configured for the
song, there may only be four plugins per song (at least in the UI.) The Plugin object has the
attributes:

=head3 attribute name

The name of the Plugin as will be displayed (determined from the plugin when it is loaded.)

=head2 attribute filename

This is the filename (a .so file typically) that the plugin was loaded from, it appears to
default to '-'.

=head3 attribute enabled

A Bool indicating whether the plugin is enabled.

=head3 attribute volume

The "volume" of the plugin.

I'm not sure how it stores the plugin specific parameters.

=end pod

use XML::Class;
use Audio::Hydrogen::Pattern;
use Audio::Hydrogen::Instrument;

class Audio::Hydrogen::Song does XML::Class[xml-element => 'song'] {
    sub from-version($v) { $v.Str }
    sub to-version($v)   { Version.new($v) }
    has Version $.version is xml-element is xml-serialise(&from-version) is xml-deserialise(&to-version) = Version.new("0.9.5");
    has Int     $.bpm               is xml-element is rw = 120;
    has Rat     $.volume            is xml-element is rw = 1.0;
    has Rat     $.metronome-volume  is xml-element('metronomeVolume') is rw;
    has Str     $.name              is xml-element is rw;
    has Str     $.author            is xml-element is rw;
    has Str     $.notes             is xml-element is rw;
    has Str     $.license           is xml-element is rw;
    has Bool    $.loop-enabled      is xml-element('loopEnabled') is rw;
    has Str     $.mode              is xml-element is rw = "pattern";
    has Rat     $.humanize-time     is xml-element('humanize_time') is rw;
    has Rat     $.humanize-velocity is xml-element('humanize_velocity') is rw;
    has Rat     $.swing-factor      is xml-element('swing_factor') is rw;
    has Audio::Hydrogen::Instrument @.instruments is xml-container('instrumentList');
    has Audio::Hydrogen::Pattern    @.patterns    is xml-container('patternList');

    class PatternGroup does XML::Class[xml-element => 'group'] {
        has @.pattern-id is xml-element('patternID');
    }

    has PatternGroup @.pattern-sequence is xml-container('patternSequence');

    class Plugin does XML::Class[xml-element => 'fx'] {
        has Str $.name  is xml-element = 'no plugin';
        has Str $.filename is xml-element = '-';
        has Bool $.enabled is xml-element = False;
        has Rat  $.volume  is xml-element = 0.0;
    }

    has Plugin @.plugins is xml-container('ladspa');
}
# vim: expandtab shiftwidth=4 ft=perl6
