use Test;

plan 58;

use lib 'lib';

use Music::Helpers;

my $mode-name = Mode.modes.pick.key;
my $mode = Mode.new(mode => $mode-name, root => NoteName.pick);

isa-ok $mode, Mode, 'Creating a random mode works';
isa-ok $mode.tonic, Chord, '...and its tonic is actually a chord';
ok $mode.tonic ~~ min|maj|dim, '...and it\'s min, maj or dim as expected';

ok $mode.tonic.notes>>.name.sort eqv $mode.tonic.invert(1).notes>>.name.sort, 
    'inverting doesn\'t add or remove notes';

{
    # i'd like this ordered, please
    my @type-to-interval =  maj      => [M3, m3],
                            min      => [m3, M3],
                            dim      => [m3, m3],
                            aug      => [M3, M3],
                            maj6     => [M3, m3, M2],
                            min6     => [m3, M3, M2],
                            dom7     => [M3, m3, m3],
                            maj7     => [M3, m3, M3],
                            min7     => [m3, M3, m3],
                            dim7     => [m3, m3, m3],
                            halfdim7 => [m3, m3, M3],
                            aug7     => [M3, M3, M2],
                            minmaj7  => [m3, M3, M3],
                            sus2     => [M2, P4],
                            sus4     => [P4, M2];

    for @type-to-interval -> (:$key, :$value) {
        my @notes = Note.new(:48midi); # C4
        @notes.push: @notes[*-1] + $_ for @$value;
        my $chord = Chord.new(:@notes);
        ok $chord.chord-type eq $key, 
            "intervals for $key chord in inversion 0 are correct";
    }
}

{
    my @type-to-interval =  maj      => [m3, P4],
                            min      => [M3, P4],
                            dim      => [m3, TT],
                            aug      => [M3, M3],
                            maj6     => [m3, M2, m3],
                            min6     => [M3, M2, m3],
                            dom7     => [m3, m3, M2],
                            maj7     => [m3, M3, m2],
                            min7     => [M3, m3, M2],
                            dim7     => [m3, m3, m3],
                            halfdim7 => [m3, M3, M2],
                            aug7     => [M3, M2, M2],
                            minmaj7  => [M3, M3, m2],
                            sus2     => [P4, P4],
                            sus4     => [M2, P4];

    for @type-to-interval -> (:$key, :$value) {
        my @notes = Note.new(:48midi);
        @notes.push: @notes[*-1] + $_ for @$value;
        my $chord = Chord.new(:@notes, :1inversion);
        ok $chord.chord-type eq $key,
            "intervals for $key chord in inversion 1 are correct";
    }
}

{
    my @type-to-interval =  maj      => [P4, M3],
                            min      => [P4, m3],
                            dim      => [TT, m3],
                            aug      => [M3, M3],
                            maj6     => [M2, m3, M3],
                            min6     => [M2, m3, m3],
                            dom7     => [m3, M2, M3],
                            maj7     => [M3, m2, M3],
                            min7     => [m3, M2, m3],
                            dim7     => [m3, m3, m3],
                            halfdim7 => [M3, M2, m3],
                            aug7     => [M2, M2, M3],
                            minmaj7  => [M3, m2, m3],
                            sus2     => [P4, M2],
                            sus4     => [P4, P4];

    for @type-to-interval -> (:$key, :$value) {
        my @notes = Note.new(:48midi);
        @notes.push: @notes[*-1] + $_ for @$value;
        my $chord = Chord.new(:@notes, :2inversion);
        ok $chord.chord-type eq $key,
            "intervals for $key chord in inversion 2 are correct";
    }
}

{
    # only testing tetrads here, inversion is already tested not to change
    # the notes of a chord, so we trust that inverting a triad three times
    # produces the original one octave higher
    my @type-to-interval =  maj6     => [m3, M3, m3],
                            min6     => [m3, m3, M3],
                            dom7     => [M2, M3, m3],
                            maj7     => [m2, M3, m3],
                            min7     => [M2, m3, M3],
                            dim7     => [m3, m3, m3],
                            halfdim7 => [M2, m3, m3],
                            aug7     => [M2, M3, M3],
                            minmaj7  => [m2, m3, M3];

    for @type-to-interval -> (:$key, :$value) {
        my @notes = Note.new(:48midi);
        @notes.push: @notes[*-1] + $_ for @$value;
        my $chord = Chord.new(:@notes, :3inversion);
        ok $chord.chord-type eq $key,
            "intervals for $key chord in inversion 3 are correct";
    }
}
