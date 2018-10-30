use lib 'lib';
use Audio::MIDI::Note;

my $stream = Audio::PortMIDI.new.open-output: 3, 32;
END { $stream.close }

my Audio::MIDI::Note $note .= new: :31tempo :30instrument :$stream :value(⅔ * ⅛);

# Looping `Gorgoroth - A World to Win` solo with organ chord in the background.
# We use tripplet notes and save repeating pieces into variables for reuse
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
            .play('G5',  ¼, :on).play('F5', ¼, :off)
            .play('D#5', ¼     ).play('D5', ¼, :off)
        .riff(&riff)
            .play('F5', ¼, :on ).play('D#5', ¼, :off)
            .play('D5', ¼      ).play('A#4', ¼, :off)
for ^10;
