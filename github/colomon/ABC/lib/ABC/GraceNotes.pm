use v6;

use ABC::Pitched;

class ABC::GraceNotes does ABC::Pitched {
    has $.acciaccatura;
    has @.notes;
    
    method new($acciaccatura, @notes) {
        die "GraceNotes must have at least one note" if +@notes == 0;
        self.bless(:$acciaccatura, :@notes);
    }

    method Str() {
        '{' ~ ($.acciaccatura ?? '/' !! '') ~ @.notes.join('') ~ '}';
    }

    method transpose($pitch-changer) {
        ABC::GraceNotes.new($.acciaccatura, @.notes>>.transpose($pitch-changer));
    }
}
