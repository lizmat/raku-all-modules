use strict;
use MinG;
use MinG::S13;
use MinG::S13::Logic;
use MinG::EDMG;

#|{
    Grammar class that parses text describing an MG lexicon.
    }
grammar MinG::From::Text::GrammarMG {
    token TOP {<header>\h*\v<lexlist>}

    rule header {\w* '=' <cat>}

    token cat {\w+}

    rule lexlist {<lex1=.lex>\h*\v<lexlist>|<lex2=.lex> }

    rule lex {<word> '::' <featlist>}

    token word {\w* | <emptycat> }

    token emptycat {'['\w+']'}

    rule featlist {<feat1=.feat>\h+<featlist>|<feat2=.feat>}

    token feat {\+\w+|\-\w+|\=\w+|\w+}
}

#|{
    Grammar class that parses EDMGs.
    }
class MinG::From::Text::GrammarEDMG is MinG::From::Text::GrammarMG {
    token feat_marker {<[\+ \- \> \< \= \@ \*]>}
    token feat {<feat_marker>\w+|\w+<feat_marker>|\w+}
}

#|{
    Class that creates a MinG::Grammar when used in conjunction with MinG::From::Text::Grammar
    }
class ConverterActionsMG {

    method TOP ($/) {
        make MinG::Grammar.new( lex => $<lexlist>.made, start_cat => $<header>.made);
    }

    method header ($/) {
        make feature_from_str($<cat>.Str);
    }

    method lexlist ($/) {
        make $<lexlist> ?? append $<lexlist>.made, $<lex1>.made !! [$<lex2>.made];
    }

    method lex ($/) {
        make MinG::LItem.new( phon => $<word>.made, features => $<featlist>.made);
    }

    method word ($/) {
        make $<emptycat> ?? "" !! $/.Str.lc;
    }

    method featlist ($/) {
        make $<featlist> ?? unshift $<featlist>.made, $<feat1>.made !! [$<feat2>.made];
    }

    method feat ($/) {
        make feature_from_str($/.Str);
    }

}

class ConverterActionsEDMG is ConverterActionsMG {
    method TOP ($/) {
        make MinG::EDMG::Grammar.new(lex => $<lexlist>.made, start_cat => $<header>.made);
    }

    method header ($/) {
        make MinG::EDMG::Feature.from_str($<cat>.Str);
    }

    method feat ($/) {
        make MinG::EDMG::Feature.from_str($/.Str);
    }
}

#|{
    Takes a string and returns the grammar that it describes.

    The format of an MG description is the following (comments are not actually allowed):

    START=C # (i.e. the start category)

    el :: =N D

    hombre :: N

    come :: =N V

    pan :: N

    :: =V =D I # this is an empty category

    no :: =V V

    :: =I C

    END

    }
sub mg_grammar_from_text(Str $s) of MinG::Grammar is export {
    return MinG::From::Text::GrammarMG.parse($s, actions => ConverterActionsMG).made;
}

#|{
    Similar to mg_grammar_from_text but for EDMGs.
    }
sub edmg_grammar_from_text(Str $s) of MinG::EDMG::Grammar is export {
    return MinG::From::Text::GrammarEDMG.parse($s, actions => ConverterActionsEDMG).made;
}

sub grammar_from_file($f) of MinG::Grammar is export {
    my $contents = $f.slurp;
    my @lines = $contents.split(/\n/);

    my regex type {'MG'|'EDMG'};
    my $type = "MG";
    if @lines[0] ~~ /^'TYPE='<type>/ {
        $type = $/<type>.Str;
        @lines = @lines[1..*];
    }
    $contents = @lines.join("\n");
    if $type eq "MG" {
        return mg_grammar_from_text($contents);
    } elsif $type eq "EDMG" {
        say $contents;
        return edmg_grammar_from_text($contents);
    } else {
        note "Wrong type of grammar in file {$f.relative}";
    }
    return Nil;
}

######################
#        TEST        #
######################
sub MAIN() {
    my $g = grammar_from_file($ESPA0);
    my $p = MinG::S13::Parser.new();
    $p.init($g);
    my @frases = ["juan saludó a maría", "juan dijo que maría saludó a pedro", "pedro era viejo", "pedro dijo que maría pensaba que juan era viejo", "el sordo pensaba que pedro saludó a maría", "maría saludó al sordo", "a maría saludó juan", "maría pensaba que pedro saludó al sordo de juan", "maría dijo que saludó a pedro", "pedro fue a la casa de juan"];
    for @frases -> $frase {
    #    $p.large_parse($frase);
    }

    $g = edmg_grammar_from_text(Q:to/END/);
    START=V
    come :: D= =D V
    juan :: D
    pan :: D
    END

    for $g.lex -> $l {
        say $l;
    }

}
