use lib 'lib';
use Audio::MIDI::Note;

my $stream = Audio::PortMIDI.new.open-output: 3, 32;
END { $stream.close }

my Audio::MIDI::Note $note .= new: :25tempo :$stream;
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
