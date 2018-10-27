use v6;

use ABC::Duration;
use ABC::Pitched;
use ABC::Note;
use ABC::Stem;

class ABC::BrokenRhythm does ABC::Duration does ABC::Pitched {
    has $.stem1;
    has $.gracing1;
    has $.broken-rhythm;
    has $.gracing2;
    has $.stem2;
    
    method new($stem1, $gracing1, $broken-rhythm, $gracing2, $stem2) {
        self.bless(:$stem1, :$gracing1, :$broken-rhythm, :$gracing2, :$stem2, 
                   :ticks($stem1.ticks + $stem2.ticks));
    }

    method broken-factor() {
        1 / 2 ** $.broken-rhythm.chars.Int;
    }
    
    method broken-direction-forward() {
        $.broken-rhythm ~~ /\>/;
    }
    
    sub new-rhythm($note, $ticks) {
        given $note {
            when ABC::Note { 
                ABC::Note.new($note.accidental,
                              $note.basenote,
                              $note.octave,
                              ABC::Duration.new(:$ticks), 
                              $note.is-tie); 
            }
            when ABC::Stem { ABC::Stem.new($note.notes.map({ new-rhythm($_, $ticks); })); }
        }
    }

    method effective-stem1() {
        new-rhythm($.stem1, self.broken-direction-forward ?? $.stem1.ticks * (2 - self.broken-factor)
                                                          !! $.stem1.ticks * self.broken-factor);
    }
    
    method effective-stem2() {
        new-rhythm($.stem2, self.broken-direction-forward ?? $.stem2.ticks * self.broken-factor
                                                          !! $.stem2.ticks * (2 - self.broken-factor));
    }

    method Str() {
        # Handle gracings here, too
        $.stem1 ~ $.broken-rhythm ~ $.stem2;
    }

    method transpose($pitch-changer) {
        ABC::BrokenRhythm.new($.stem1.transpose($pitch-changer), 
                              $.gracing1,
                              $.broken-rhythm,
                              $.gracing2,
                              $.stem2.transpose($pitch-changer));
    }
}
