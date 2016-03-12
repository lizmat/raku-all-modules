use v6.c;

=begin pod

=head1 NAME

Audio::Hydrogen::Instrument - represent a hydrogen instrument

=head1 DESCRIPTION

Instruments are found primarily in L<Audio::Hydrogen::Drumkit>
object from where they are used in songs.  An instrument comprises
at least one audio sample in WAV or FLAC format with various settings
that may change the way it sounds.  Most of the attributes have
reasonable defaults.

=head1 METHODS

=head2 attribute id

This is required and must be unique in either a drumkit or song
where it is used, typically it is in the range 0 - 31.  If you
are copying individual instruments from different drumkits into
a song you may need to change the C<id> so that they remain unique.

The id is referenced in the patterns of a song so you probably
don't want to change it after any patterns have been created
(unless of course you actually want to change the played instrument.)

=head2 attribute name

This is the free text name of the instrument, it must be set if
the instrument is to be usable in the Hydrogen interface as the
absence of a name may be taken as being an "empty instrument".

=head2 attribute filename

This is the name of the sample file that should be either a WAV
or FLAC format, if used in a drumkit it may be relative to the
drumkit directory, if the instrument is being used in a song
then this should be an absolute path.

If this is empty then there is expected to be one or more layer
specified as described below.

=head2 attribute volume

This is the volume of the instrument a Rat in the range 0 .. 1.0
The default is 1.0

=head2 attribute is-muted

This is a boolean to indicate whether the instrument is muted,
typically not used in a drumkit but may be used in a song.

=head2 attribute is-locked

If this bool is set, the instrument settings can't be changed in
the interface.

=head2 attribute pan-left

This is a Rat in the range 0 .. 1.0 to indicate the panning to the
left side. 

=head2 attribute pan-right

This is a Rat in the range 0 .. 1.0 to indicate the panning to the
right side.


=head2 attribute random-pitch-factor

This is a Rat in the range 0 .. 1.0 that appears to indicate a range of
variation of the playback speed of the sample, the default is 0.0

=head2 attribute gain

This is a gain factor in the range 0 .. 1.0 that is applied to the
sample. The default is 1.

=head2 attribute filter-active

This is a boolean to indicate whether the low pass filter is engaged,
the default is False.

=head2 attribute filter-cutoff

This is a Rat in the range 0 .. 1.0 that indicates the filter cutoff
frequency, 0 is the lowest cutoff which effectively doesn't pass anything
and 1.0 sounds like it passes everything.

=head2 attribute filter-resonance

This is a Rat in the range 0 .. 1.0 that indicates the low pass filter
resonance (i.e. gain applied around the filter cutoff frequency or
feedback,) it is a more marked effect in the middle range of cutoff
frequency.

=head2 attribute attack

This is the length of time that is taken for the sample to be played at
full volume, the default is 0, obviously some values may be longer than
the sample length and it won't be played at all.

=head2 attribute decay

This is the length of time taken after the attack part for the level to
go to the sustain level, the default is 0.

=head2 attribute sustain

This is the level at which the sustained part of the sample is played,
the default is 1 (i.e. full volume.)

=head2 attribute release

This is the length of time the sample takes for the volume to reduce to
0, the default is 1000.  The net result of the default settings for the
envelope is that the sample is played verbatim.


=head2 attribute exclude

I've never seen a file with this in and don't know what it is. If you
know please let me know.

=head2 attribute layer

This is a list of L<Audio::Hydrogen::Instrument::Layer> objects, these
provide a way of specifying different samples to be used depending on
the velocity of a note in a pattern. If this is empty then C<filename>
must be specified, (or vice versa.)

The Audio::Hydrogen::Instrument::Layer class has the following attributes:

=head3 attribute filename

This is the filename of a FLAC or WAV sample that will be played for this
layer, if this being used in a drumkit it can be relative to the drumkit
directory, if used in a song it should be an absolute path.

=head3 attribute min

This is the minimum velocity that this layer should be used for, it is a
Rat in the range of 0 .. 1.0,

=head3 attribute max

This is the maximum velocity that this layer should be used for, it is a
Rat in the range of 0 .. 1.0 

=head3 attribute gain

The gain factor to be applied to the sample for this layer.

=head3 attribute pitch

The pitch that the sample should be played back at for this layer.


=head2 method make-absolute

This method should be called on the instrument when it is being
copied from a drumkit to a song.  It takes an L<IO::Path> that
should be the directory containing the drumkit and will make the
sample filenames explicitly children of that path.

=end pod

use XML::Class;

class Audio::Hydrogen::Instrument does XML::Class[xml-element => 'instrument'] {
    has Int  $.id                  is xml-element;
    has Str  $.name                is xml-element is rw;
    has Str  $.filename            is xml-element is rw;
    has Rat  $.volume              is xml-element is rw = 1.0;
    has Bool $.is-muted            is xml-element('isMuted') is rw = False;
    has Bool $.is-locked           is xml-element('isLocked') is rw = False;
    has Rat  $.pan-left            is xml-element('pan_L') is rw = 1.0;
    has Rat  $.pan-right           is xml-element('pan_R') is rw = 1.0;
    has Rat  $.random-pitch-factor is xml-element('randomPitchFactor') is rw = 0.0;
    has Int  $.gain                is xml-element is rw = 1;
    has Bool $.filter-active       is xml-element('filterActive') is rw  = False;
    has Rat  $.filter-cutoff       is xml-element('filterCutoff') is rw;
    has Rat  $.filter-resonance    is xml-element('filterResonance') is rw;
    has Int  $.attack              is xml-element('Attack') is rw = 0;
    has Int  $.decay               is xml-element('Decay') is rw  = 0;
    has Int  $.sustain             is xml-element('Sustain') is rw = 1;
    has Int  $.release             is xml-element('Release') is rw = 1000;
    has      $.exclude             is xml-element;

    class Layer does XML::Class[xml-element => 'layer'] {
        has Str $.filename is rw is xml-element;
        has Rat $.min      is xml-element is rw;
        has Rat $.max      is xml-element is rw;
        has Int $.gain     is xml-element is rw;
        has Int $.pitch    is xml-element is rw = 0;
    }

    has Layer @.layer;

    method make-absolute(IO::Path $path) {
        if $!filename && !$!filename.IO.is-absolute {
            $!filename = $path.child($!filename).Str;
        }
        for @!layer ->  $layer {
            if !$layer.filename.IO.is-absolute {
                my $new-path = $path.child($layer.filename).Str;
                $layer.filename = $new-path;
            }
        }
    }
}


# vim: expandtab shiftwidth=4 ft=perl6
