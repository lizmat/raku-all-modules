use v6;

=begin pod

=head1 NAME

Audio::Hydrogen::Pattern - a single pattern

=head1 DESCRIPTION

A Pattern comprises a set of notes each associated with
a specific instrument arranged over time. The unit of
"time" or position is 48 parts per quarter note (MIDI
uses 24 for MIDI clock, some hardware sequencers may
do 96 or even higher,) thus a "bar" with the 4/4 
time signature has a length of 192 possible positions.

=head1 METHODS

=head2 attribute name

This is a short name that will be used in the Hydrogen
UI and is referenced by the Song's "pattern group". It
is required and should be unique when used in a Song.

=head2 attribute category

This is a free text category name, it defaults to "not_categorized".
Specific categories may be used by the software but there isn't
a list.

=head2 attribute size

This is a positive Int which is the length of the pattern, this
is based on 48 per quarter note (so 1/192 of a note is the 
minimum resolution.) The default is 192 which would represent
a single bar at the 4/4 time signature.

=head2 attribute note-list

This is a list of Audio::Hydrogen::Playlist::Note objects which
may be ordered by position,

=head3 attribute position

The Int position in 48ppqn as described between 0 and size - 1
where 0 is the beginning of the bar. Because the resolution
may be finer than that configured in the UI, some notes may
not show up aligned to the grid in the UI, you may need to
increase the UI resolution to correctly edit these notes.

=head3 attribute lead-lag

This is an integer in the 1/48 parts that indicates
the delay between the note position and the note
actually sounding, it defaults to 0.

=head3 attribute velocity

This is a Rat between 0 and 1.0 that specifies the
"velocity" of the note, which may affect the volume
of the note as played or which layer is selected to
be played for an instrument with more than one layer.

The default is 1.0 for newly created objects but
Hydrogen itself seems to default to 0.8.

=head3 attribute instrument

This is the Int instrument id of the instrument that this note is to be played on.
It must refer to a valid instrument in the Song in which the pattern is used to
be played, it is possible for a pattern to be saved standalone so it can be left
blank.

=head3 attribute pan-left

The Rat amount the sound is panned to the left in the
output, it defaults to 0.5

=head3 attribute pan-right

The Rat amount the sound is panned to the right in the
output, it defaults to 0.5

=head3 attribute pitch

An Int pitch factor for pitched instruments, it defaults to 0.

=head3 attribute note

This is the note that would be played for a pitched instrument
it defaults to 'C'. 

=head3 attribute length

This is the note length in 48ppqn "ticks", it is only used for pitched instruments.
Hydrogen defaults this to -1 but it can be left empty.

=head3 attribute note-off

This is a Bool to indicate whether the length should be used, it defaults to False.

=end pod

use XML::Class;

class Audio::Hydrogen::Pattern does XML::Class[xml-element => 'pattern'] {
    has Str $.name     is xml-element is rw is required;
    has Str $.category is xml-element is rw = 'not_categorized';
    has Int $.size     is xml-element is rw = 192;

    class Note does XML::Class[xml-element => 'note'] {
        has Int  $.position   is xml-element is rw;
        has Int  $.lead-lag   is xml-element('leadLag') is rw = 0;
        has Rat  $.velocity   is xml-element is rw  = 1.0;
        has Rat  $.pan-left   is xml-element('pan_L') is rw   = 0.5;
        has Rat  $.pan-right  is xml-element('pan_R') is rw   = 0.5;
        has Int  $.pitch      is xml-element is rw            = 0;
        has Str  $.note       is xml-element is rw           = 'C';
        has Int  $.length     is xml-element is rw;
        has Bool $.note-off   is xml-element is rw = False;
        has Int  $.instrument is xml-element is rw;
    }

    has Note @.note-list     is xml-container('noteList');
}
# vim: expandtab shiftwidth=4 ft=perl6
