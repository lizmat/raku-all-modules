use v6;

use ABC::Duration;
use ABC::Pitched;

class ABC::Note does ABC::Duration does ABC::Pitched {
    has $.accidental;
    has $.basenote;
    has $.octave;
    has $.is-tie;
    
    method new($accidental, $basenote, $octave, ABC::Duration $duration, $is-tie) {
        self.bless(:$accidental, :$basenote, :$octave, :ticks($duration.ticks), :$is-tie);
    }

    method pitch() {
        $.accidental ~ $.basenote ~ $.octave;
    }

    method Str() {
        $.pitch ~ self.duration-to-str ~ ($.is-tie ?? "-" !! "");
    }

    method perl() {
        "ABC::Note.new({ $.accidental.perl }, { $.basenote.perl }, { $.octave.perl } { $.ticks.perl }, { $.is-tie.perl })";
    }

    method transpose($pitch-changer) {
        my ($new-accidental, $new-basenote, $new-octave) = $pitch-changer($.accidental, $.basenote, $.octave);
        ABC::Note.new($new-accidental, $new-basenote, $new-octave, self, $.is-tie);
    }
}
