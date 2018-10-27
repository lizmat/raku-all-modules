use v6;
use ABC::Pitched;

class ABC::Chord does ABC::Pitched {
    has $.main-note;
    has $.main-accidental;
    has $.main-type;
    has $.bass-note;
    has $.bass-accidental;

    method new($main-note, $main-accidental, $main-type, $bass-note, $bass-accidental) {
        self.bless(:$main-note, :$main-accidental, :$main-type, :$bass-note, :$bass-accidental);
    }

    method Str() {
        '"' ~ $.main-note 
            ~ $.main-accidental 
            ~ $.main-type 
            ~ ($.bass-note ?? '/' ~ $.bass-note ~ $.bass-accidental !! "")
            ~ '"';
    }

    method perl() {
        "ABC::Chord.new({ $.main-note.perl }, { $.main-accidental.perl }, { $.main-type.perl }, { $.bass-note.perl }, { $.bass-accidental.perl })";
    }

    method transpose($pitch-changer) {
        sub change-chord($note, $accidental) {
            my $note-accidental;
            given $accidental {
                when '#' { $note-accidental = '^' }
                when 'b' { $note-accidental = '_' }
                $note-accidental = '=';
            }
            my ($new-accidental, $new-note, $new-octave) = $pitch-changer($note-accidental, $note, "");
            given $new-accidental {
                when '^' { $new-accidental = '#' } 
                when '_' { $new-accidental = 'b' } 
                when '=' { $new-accidental = ''  } 
                when ''  { $new-accidental = ''  }
                die "Unable to handle $new-accidental in a chord name";
            }
            ($new-note.uc, $new-accidental);
        }
        
        my ($main-note, $main-accidental) = change-chord($.main-note, $.main-accidental);
        my ($bass-note, $bass-accidental) = change-chord($.bass-note, $.bass-accidental);
        ABC::Chord.new($main-note, $main-accidental, $.main-type, $bass-note, $bass-accidental);
    }
}