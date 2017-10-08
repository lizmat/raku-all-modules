use v6;

use ABC::Duration;
use ABC::Pitched;

class ABC::Stem does ABC::Duration does ABC::Pitched {
    has @.notes;
    has $.is-tie;
    
    method new(@notes, ABC::Duration $duration, $is-tie) {
        die "Stem must have at least one note" if +@notes == 0;
        self.bless(:@notes, :ticks(@notes>>.ticks.max * $duration.ticks), :$is-tie);
    }

    method Str() {
        "[" ~ @.notes.join("") ~ "]" ~ ($.is-tie ?? "-" !! "");
    }

    method transpose($pitch-changer) {
        ABC::Stem.new(@.notes>>.transpose($pitch-changer), self, $.is-tie);
    }
}
