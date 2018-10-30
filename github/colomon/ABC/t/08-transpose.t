use v6;
use Test;

use ABC::Grammar;
use ABC::Header;
use ABC::Tune;
use ABC::Duration;
use ABC::Note;
use ABC::Rest;
use ABC::Tuplet;
use ABC::BrokenRhythm;
use ABC::Chord;
use ABC::LongRest;
use ABC::GraceNotes;
use ABC::Actions;
use ABC::Utils;
use ABC::Pitched;
use ABC::KeyInfo;

sub transpose(Str $test, $pitch-changer) {
    my $match = ABC::Grammar.parse($test, :rule<element>, :actions(ABC::Actions.new));
    if $match {
        given $match.ast.value {
            when Positional { $_>>.transpose($pitch-changer); }
            when ABC::Pitched { $_.transpose($pitch-changer); }
            die "Don't know how to transpose { $_.WHAT }";
        }
    }
}

sub up-octave($accidental, $basenote, $octave) {
    if $octave ~~ /","/ {
        return ($accidental, $basenote, $/.postmatch);
    } elsif $octave ~~ /"'"/ || $basenote ~~ /<lower>/ {
        return ($accidental, $basenote, $octave ~ "'");
    } else {
        return ($accidental, $basenote.lc, $octave);
    }
}

is transpose("A", &up-octave), "a", "Octave bump to A yields a";
is transpose("a", &up-octave), "a'", "Octave bump to a yields a'";
is transpose("a''2", &up-octave), "a'''2", "Octave bump to a'' yields a'''";
is transpose("A,-", &up-octave), "A-", "Octave bump to A, yields A";
is transpose("A,,", &up-octave), "A,", "Octave bump to A,, yields A,";
is transpose("[C,Eg]", &up-octave), "[Ceg']", "Octave bump to [C,Eg] yields [Ceg']";
is transpose("[C,Eg]", &up-octave), "[Ceg']", "Octave bump to [C,Eg] yields [Ceg']";
is transpose("(3C,Eg", &up-octave), "(3Ceg'", "Octave bump to (3C,Eg yields (3Ceg'";
is transpose("A<a", &up-octave), "a<a'", "Octave bump to A<a yields a<a'";
is transpose('{Bc}', &up-octave), '{bc\'}', "Octave bump to Bc yields bc'";
is transpose('"Amin/F"', &up-octave), '"Amin/F"', "Octave bump to chord yields no change";

sub pitch2ordinal(%key, $test) {
    my $match = ABC::Grammar.parse($test, :rule<mnote>, :actions(ABC::Actions.new));
    if $match {
        pitch-to-ordinal(%key, $match.ast.accidental, $match.ast.basenote, $match.ast.octave);
    }
}

{
    my %key = ABC::KeyInfo.new("C").key;
    is pitch2ordinal(%key, "C"), 0,  "C ==> 0";
    is pitch2ordinal(%key, "D"), 2,  "D ==> 2";
    is pitch2ordinal(%key, "E"), 4,  "E ==> 4";
    is pitch2ordinal(%key, "F"), 5,  "F ==> 5";
    is pitch2ordinal(%key, "G"), 7,  "G ==> 7";
    is pitch2ordinal(%key, "A"), 9,  "A ==> 9";
    is pitch2ordinal(%key, "B"), 11, "B ==> 11";
    is pitch2ordinal(%key, "c"), 12, "c ==> 12";
    is pitch2ordinal(%key, "=A"), 9, "=A ==> 9";
    is pitch2ordinal(%key, "^A"), 10, "^A ==> 10";
    is pitch2ordinal(%key, "_A"), 8,  "_A ==> 8";
    is pitch2ordinal(%key, "^^A"), 11, "^^A ==> 11";
    is pitch2ordinal(%key, "__A"), 7,  "__A ==> 7";
    is pitch2ordinal(%key, "^^G,,,"), -27, "^^G,,, ==> -27";
    is pitch2ordinal(%key, "d'''"), 50, "d''' ==> 50";
    
    %key = ABC::KeyInfo.new("Ab").key;
    is pitch2ordinal(%key, "C"), 0,  "C ==> 0";
    is pitch2ordinal(%key, "D"), 1,  "D ==> 1";
    is pitch2ordinal(%key, "E"), 3,  "E ==> 3";
    is pitch2ordinal(%key, "F"), 5,  "F ==> 5";
    is pitch2ordinal(%key, "G"), 7,  "G ==> 7";
    is pitch2ordinal(%key, "A"), 8,  "A ==> 8";
    is pitch2ordinal(%key, "B"), 10, "B ==> 10";
    is pitch2ordinal(%key, "c"), 12, "c ==> 12";
    is pitch2ordinal(%key, "=A"), 9, "=A ==> 9";
    is pitch2ordinal(%key, "^A"), 10, "^A ==> 10";
    is pitch2ordinal(%key, "_A"), 8,  "_A ==> 8";
    is pitch2ordinal(%key, "^^A"), 11, "^^A ==> 11";
    is pitch2ordinal(%key, "__A"), 7,  "__A ==> 7";
    is pitch2ordinal(%key, "^^G,,,"), -27, "^^G,,, ==> -27";
    is pitch2ordinal(%key, "d'''"), 49, "d''' ==> 49";
   
    %key = ABC::KeyInfo.new("C").key;
    is ordinal-to-pitch(%key, "C", 0), " C ", "0/C => C";
    is ordinal-to-pitch(%key, "D", 0), "__ D ", "0/D => __D";
    is ordinal-to-pitch(%key, "B", 0), "^ B ,", "0/B => ^B,";
    is ordinal-to-pitch(%key, "C", 1), "^ C ", "1/C => ^C";
    is ordinal-to-pitch(%key, "D", 1), "_ D ", "1/D => _D";
    is ordinal-to-pitch(%key, "B", 1), "^^ B ,", "1/B => ^^B,";
    is ordinal-to-pitch(%key, "C", -1), "_ C ", "-1/C => _C";
    is ordinal-to-pitch(%key, "B", -1), " B ,", "-1/B => B,";
    is ordinal-to-pitch(%key, "C", -12), " C ,", "-12/C => C,";
    is ordinal-to-pitch(%key, "D", -12), "__ D ,", "-12/D => __D,";
    is ordinal-to-pitch(%key, "B", -12), "^ B ,,", "-12/B => ^B,,";
    is ordinal-to-pitch(%key, "C", 11), "_ c ", "11/C => _c";
    is ordinal-to-pitch(%key, "B", 11), " B ", "11/B => B";
    is ordinal-to-pitch(%key, "C", 12), " c ", "12/C => c";
    is ordinal-to-pitch(%key, "D", 12), "__ d ", "12/D => __d";
    is ordinal-to-pitch(%key, "B", 12), "^ B ", "12/B => ^B";
    is ordinal-to-pitch(%key, "C", 13), "^ c ", "1/C => ^c";
    is ordinal-to-pitch(%key, "D", 13), "_ d ", "1/D => _d";
    is ordinal-to-pitch(%key, "B", 13), "^^ B ", "1/B => ^^B";
    is ordinal-to-pitch(%key, "C", 23), "_ c '", "23/C => _c'";
    is ordinal-to-pitch(%key, "B", 23), " b ", "23/B => b";
    is ordinal-to-pitch(%key, "C", 24), " c '", "24/C => c'";
    is ordinal-to-pitch(%key, "D", 24), "__ d '", "24/D => __d'";
    is ordinal-to-pitch(%key, "B", 24), "^ b ", "24/B => ^b";
    is ordinal-to-pitch(%key, "C", 25), "^ c '", "25/C => ^c'";
    is ordinal-to-pitch(%key, "D", 25), "_ d '", "25/D => _d'";
    is ordinal-to-pitch(%key, "B", 25), "^^ b ", "25/B => ^^b";
}

sub e-flat-to-d($accidental, $basenote, $octave) {
    my %e-flat = ABC::KeyInfo.new("Eb").key;
    my %d = ABC::KeyInfo.new("D").key;
    my $ordinal = pitch-to-ordinal(%e-flat, $accidental, $basenote, $octave);
    my $basenote-in-d = $basenote.uc eq "A" ?? "G" !! ($basenote.ord - 1).chr.uc;
    ordinal-to-pitch(%d, $basenote-in-d, $ordinal - 1);
}

is transpose("A", &e-flat-to-d), "G", "Eb to D on A yields G";
is transpose("a", &e-flat-to-d), "g", "Eb to D on a yields g";
is transpose("a''2", &e-flat-to-d), "g''2", "Eb to D on a'' yields g''";
is transpose("A,-", &e-flat-to-d), "G,-", "Eb to D on A,- yields G,-";
is transpose("[_EG_B]", &e-flat-to-d), "[DFA]", "Eb to D on [_EG_B] yields [DFA]";
is transpose("[EGB]", &e-flat-to-d), "[DFA]", "Eb to D on [EGB] yields [DFA]";
is transpose("(3C,Eg", &e-flat-to-d), "(3B,,Df", "Eb to D on (3C,Eg yields (3B,,Df";
is transpose("=A<a", &e-flat-to-d), "^G<g", "Eb to D on =A<a yields ^G<g";
is transpose('{Bc}', &e-flat-to-d), '{AB}', "Eb to D on Bc yields AB";
is transpose('"Amin/F"', &e-flat-to-d), '"G#min/E"', "Eb to D on Amin/F yields G#min/E";
is transpose('"Abmin/F"', &e-flat-to-d), '"Gmin/E"', "Eb to D on Abmin/F yields Gmin/E";

class Transposer {
    has %.key-changes;
    has $.half-step-shift;
    has $.pitch-name-shift;
    has %.current-from;
    has %.current-to;

    multi method new(%key-changes, $half-step-shift) {
        self.bless(:%key-changes, :$half-step-shift);
    }

    method set-key($new-key) {
        %.current-from = ABC::KeyInfo.new($new-key).key;
        %.current-to = ABC::KeyInfo.new(%.key-changes{$new-key}).key;
        # $.pitch-name-shift = $new-key.
        
    }

    method postcircumfix:<( )>($accidental, $basenote, $octave) {
        my $ordinal = pitch-to-ordinal(%.current-from, $accidental, $basenote, $octave);
        my $basenote-in-new-key = "A".ord + ($basenote.uc.ord - "A".ord + $.pitch-name-shift) % 7;
        ordinal-to-pitch(%.current-to, $basenote-in-new-key, $ordinal + $.half-step-shift);
    }
}


done-testing;
