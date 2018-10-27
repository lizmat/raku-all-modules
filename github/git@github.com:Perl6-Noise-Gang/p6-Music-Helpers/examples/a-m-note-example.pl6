use Audio::PortMIDI;
use Audio::MIDI::Note;
use Music::Helpers;

sub MAIN(Str :$mode = 'major', Str :$root = 'C') {
    my $Mode = Mode.new(:$mode, root => ::($root));

    my $pm = Audio::PortMIDI.new;
    my $stream = $pm.open-output(3, 32);
    
    my $keys  = Audio::MIDI::Note.new(:tempo(120), :$stream, :value(1), :velocity(85), :channel(0));
    my @chords = $Mode.chords.eager.grep({ 2 < $_.root.octave < 4 }).pick(4);
    
    my &chordloop = sub ($note, @inner-chords is copy) {
        .Str.say for @inner-chords;
        $note.play(@inner-chords[$++ % *].notes.map(~*).eager) for ^8;
    };

    my &riff = &chordloop.assuming(*, my @ = @chords);

    my $key-promise = start { $keys.riff(&riff) };

    @chords = do [ .^can('variant-methods') ?? ($_.variant-methods.pick)($_) !! $_  for @chords ];
    &riff = &chordloop.assuming(*, my @ = @chords);

    await $key-promise;
    $key-promise = start { $keys.riff(&riff) };
    await $key-promise;
}
