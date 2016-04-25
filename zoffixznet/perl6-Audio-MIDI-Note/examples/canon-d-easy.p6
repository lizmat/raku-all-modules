use lib 'lib';
use Audio::MIDI::Note;

my $stream = Audio::PortMIDI.new.open-output: 3, 32;
END { $stream.close }

my Audio::MIDI::Note $note .= new: :20tempo :$stream, :value(½), :49velocity;

# Pachelbel `Canon in D`
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




=finish
# 'Titanic' Theme: http://www.musicnotes.com/sheetmusic/mtd.asp?ppn=MN0062768

my &main = { # first two bars that repeat throughout the song
    .aplay(<F3 A3>, 1).play('F4', ¼+⅛).play('F4', ⅛).play('F4').play('F4')
    .aplay(<C3 G3>, 1).play('E4').play('F4', ½).play('E4');
};

$note   .riff(&main)
        .aplay(<Bb2 F3>, 1).play('E4').play('F4', ½).play('G4')
        .play(<F2 F4 A4>, ½).play(<C3 E4 G4>, ½)

        .riff(&main)
        .play(<Bb2 F3 C4>, 1).play('Bb2').play('C3').play('D3').play('G3')
;
