use v6;

use ABC::Duration;
use ABC::Pitched;

class ABC::Tuplet does ABC::Duration does ABC::Pitched {
    has $.p;
    has $.q;
    has @.notes;
    
    multi method new($p, @notes) {
        self.new($p, default-q($p), @notes);
    }

    multi method new($p, $q, @notes) {
        die "Tuplet must have at least one note" if +@notes == 0;
        self.bless(:$p, :$q, :@notes, :ticks($q/$p * [+] @notes>>.ticks));
    }

    sub default-q($p) {
        given $p {
            when 3 | 6     { 2; }
            when 2 | 4 | 8 { 3; }
            default        { 2; } # really need to know the time signature for this!
        }
    }

    method Str() {
        my $q = $.q != default-q($.p) ?? $.q !! "";
        my $r = @.notes != $.p ?? +@.notes !! "";
        if $q eq "" && $r eq "" {
            "(" ~ $.p ~ @.notes.join("");
        } else {
            "(" ~ $.p ~ ":" ~ $q ~ ":" ~ $r ~ @.notes.join("");
        }
    }

    method transpose($pitch-changer) {
        ABC::Tuplet.new($.tuple, @.notes>>.transpose($pitch-changer));
    }

    method tuple() { $.p; } # for backwards compatibility, probably needs to go in the long run
}
