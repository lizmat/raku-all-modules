use v6;

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

class ABC::Actions {
    has $.current-tune = "";
    
    method header_field($/) {
        if $<header_field_name> eq "T" {
            $*ERR.say: "Parsing " ~ $<header_field_data>;
            $!current-tune = $<header_field_data> ~ "\n";
        }
        
        make ~$<header_field_name> => ~$<header_field_data>;
    }
    
    method interior_header_field($/) {
        make ~$<interior_header_field_name> => ~$<interior_header_field_data>;
    }
    
    method header($/) { 
        my $header = ABC::Header.new;
        for @( $<header_field> ) -> $field {
            $header.add-line($field.ast.key, $field.ast.value);
        }
        make $header;
    }
    
    method note_length($/) {
        if $<note_length_denominator> {
            if $<note_length_denominator> ~~ Parcel {
                make duration-from-parse($<top>, $<note_length_denominator>[0]<bottom>);
            } else {
                make duration-from-parse($<top>, $<note_length_denominator><bottom>);
            }
        } else {
            make duration-from-parse($<top>);
        }
    }
    
    method mnote($/) {
        make ABC::Note.new(~($<pitch><accidental> // ""),
                           ~$<pitch><basenote>,
                           ~($<pitch><octave> // ""),
                           $<note_length>.ast, 
                           ?$<tie>);
    }
    
    method stem($/) {
        if @( $<mnote> ) == 1 {
            make $<mnote>[0].ast;
        } else {
            make ABC::Stem.new(@( $<mnote> )>>.ast, $<note_length>.ast, ?$<tie>);
        }
    }
    
    method rest($/) {
        make ABC::Rest.new(~$<rest_type>, $<note_length>.ast);
    }

    method multi_measure_rest($/) {
        make ABC::LongRest.new(~$<number>);
    }
    
    method tuplet($/) {
        make ABC::Tuplet.new(+@( $<stem> ), @( $<stem> )>>.ast);
    }

    method nth_repeat_num($/) {
        my @nums = $/.subst("-", "..").EVAL;
        make @nums.Set;
    }

    method nth_repeat($/) {
        make ($<nth_repeat_num> // $<nth_repeat_text>).ast;
    }

    method broken_rhythm($/) {
        make ABC::BrokenRhythm.new($<stem>[0].ast, 
                                   ~$<g1>, 
                                   ~$<broken_rhythm_bracket>, 
                                   ~$<g2>,
                                   $<stem>[1].ast);
    }

    method grace_note($/) {
        make ABC::Note.new(~($<pitch><accidental> // ""),
                           ~$<pitch><basenote>,
                           ~($<pitch><octave> // ""),
                           $<note_length>.ast,
                           False);
    }
    
    method grace_note_stem($/) {
        if @( $<grace_note> ) == 1 {
            make $<grace_note>[0].ast;
        } else {
            make ABC::Stem.new(@( $<grace_note> )>>.ast);
        }
    }

    method grace_notes($/) {
        make ABC::GraceNotes.new(?$<acciaccatura>, @( $<grace_note_stem> )>>.ast);
    }

    
    method inline_field($/) {
        make ~$/<alpha> => ~$/<value>;
    }
    
    method long_gracing($/) {
        make ~$/<long_gracing_text>;
    }

    method gracing($/) {
        make $/<long_gracing> ?? $/<long_gracing>.ast !! ~$/;
    }
    
    method slur_begin($/) {
        make ~$/;
    }
    
    method slur_end($/) {
        make ~$/;
    }
    
    method chord($/) {
        # say "hello?";
        # say $/<chord_accidental>[0].WHAT;
        # say $/<chord_accidental>[0].perl;
        make ABC::Chord.new(~$/<mainnote>, ~($/<mainaccidental> // ""), ~($/<maintype> // ""), 
                            ~($/<bassnote> // ""), ~($/<bass_accidental> // ""));
    }
    
    method chord_or_text($/) {
        my @chords = $/<chord>.for({ $_.ast });
        my @texts = $/<text_expression>.for({ ~$_ });
        make (@chords, @texts).flat;
    }
    
    method element($/) {
        my $type;
        for <broken_rhythm stem rest slur_begin slur_end multi_measure_rest gracing grace_notes nth_repeat end_nth_repeat spacing tuplet inline_field chord_or_text> {
            $type = $_ if $/{$_};
        }
        # say $type ~ " => " ~ $/{$type}.ast.WHAT;
        
        my $ast = $type => ~$/{$type};
        # say :$ast.perl;
        # say $/{$type}.ast.perl;
        # say $/{$type}.ast.WHAT;
        if $/{$type}.ast ~~ ABC::Duration | ABC::LongRest | ABC::GraceNotes | Pair | Str | List | Set {
            $ast = $type => $/{$type}.ast;
        }
        make $ast;
    }
    
    method barline($/) { 
        make "barline" => ~$/;
    }
    
    method bar($/) {
        $!current-tune ~= ~$/;
        my @bar = @( $<element> )>>.ast;
        if $<barline> {
            @bar.push($<barline>>>.ast);
        }
        make @bar;
    }
    
    method line_of_music($/) {
        my @line;
        if $<barline> {
            @line.push($<barline>>>.ast);
        }
        my @bars = @( $<bar> )>>.ast;
        for @bars -> $bar {
            for $bar.list {
                @line.push($_);
            }
        }
        @line.push("endline" => "");
        $!current-tune ~= "\n";
        make @line;
    }
    
    method music($/) {
        my @music;
        # $*ERR.say: "Started music action";
        for @( $/.caps ) {
            # $*ERR.say: ~$_.key ~ " => " ~ ~$_.value;
            when *.key eq "line_of_music" {
                for $_.value.ast {
                    @music.push($_);
                }
            }
            when *.key eq "interior_header_field" {
                @music.push("inline_field" => $_.value.ast);
            }
        }
        # state $count = 0;
        # die if ++$count == 10;
        make @music;
    }
    
    method tune($/) {
        make ABC::Tune.new($<header>.ast, $<music>.ast);
    }
    
    method tune_file($/) {
        make @( $<tune> )>>.ast;
    }
}