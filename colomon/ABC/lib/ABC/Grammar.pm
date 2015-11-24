use v6;
# use Grammar::Tracer;

grammar ABC::Grammar
{
    regex comment { \h* '%' \N* $$ }
    regex comment_line { ^^ <comment> }
    
    token header_field_name { \w }
    token header_field_data { <-[ % \v ]>* }
    token header_field { ^^ <header_field_name> ':' \h* <header_field_data> <comment>? $$ }
    token header { [[<header_field> | <comment_line>] \v+]+ }

    token basenote { <[a..g]+[A..G]> }
    token octave { "'"+ | ","+ }
    token accidental { '^^' | '^' | '__' | '_' | '=' }
    token pitch { <accidental>? <basenote> <octave>? }

    token tie { '-' }
    token number { <digit>+ }
    token note_length_denominator { '/' <bottom=number>? }
    token note_length { <top=number>? <note_length_denominator>? }
    token mnote { <pitch> <note_length> <tie>? }
    token stem { <mnote> | [ '[' <mnote>+ ']' <note_length> <tie>? ]  }
    
    token rest_type { <[x..z]> }
    token rest { <rest_type> <note_length> }
    token multi_measure_rest { 'Z' <number> }
    
    token slur_begin { '(' }
    token slur_end { ')' }
    
    token grace_note { <pitch> <note_length> } # as mnote, but without tie
    token grace_note_stem { <grace_note> | [ '[' <grace_note>+ ']' ]  }
    token acciaccatura { '/' }
    token grace_notes { '{' <acciaccatura>? <grace_note_stem>+ '}' }
    
    token long_gracing_text { [<alpha> | '.' | ')' | '(']+ }
    token long_gracing { '+' <long_gracing_text> '+' }
    token gracing { '.' | '~' | 'T' | <long_gracing> }
    
    token spacing { \h+ }
    
    token broken_rhythm_bracket { ['<'+ | '>'+] }
    token b_elem { <gracing> | <grace_notes> | <slur_begin> | <slur_end> }
    token broken_rhythm { <stem> <g1=b_elem>* <broken_rhythm_bracket> <g2=b_elem>* <stem> }
    
    token t_elem { <gracing> | <grace_notes> | <broken_rhythm> | <slur_begin> | <slur_end> }
    # token tuplet { '('(<digit>+) {} [<t_elem>* <stem>] ** { +$0 } <slur_end>? }
    # If the previous line fails, you can use the next rule to get the most common cases
    # next block makes the most common cases work
    # token tuplet { '(' (<digit>+) {} (<t_elem>* <stem>)*? <?{ say $1.perl; say $0.perl; $1.elems == $0 }> <slur_end>? }
    token tuplet { ['(2' [<t_elem>* <stem>] ** 2 <slur_end>? ] 
                 | ['(3' [<t_elem>* <stem>] ** 3 <slur_end>? ]
                 | ['(4' [<t_elem>* <stem>] ** 4 <slur_end>? ]
                 | ['(5' [<t_elem>* <stem>] ** 5 <slur_end>? ] }
    
    token nth_repeat_num { <digit>+ [[',' | '-'] <digit>+]* }
    token nth_repeat_text { '"' .*? '"' }
    token nth_repeat { ['[' [ <nth_repeat_num> | <nth_repeat_text> ]] | [<?after '|'> <nth_repeat_num>] }
    token end_nth_repeat { ']' }
    
    regex inline_field { '[' <alpha> ':' $<value>=[.*?] ']' }
    
    token chord_accidental { '#' | 'b' | '=' }
    token chord_type { [ <alpha> | <digit> | '+' | '-' ]+ }
    token chord_newline { '\n' | ';' }
    token chord { <mainnote=basenote> <mainaccidental=chord_accidental>? <maintype=chord_type>? 
                  [ '/' <bassnote=basenote> <bass_accidental=chord_accidental>? ]? <non_quote>* } 
    token non_quote { <-["]> }
    token text_expression { [ '^' | '<' | '>' | '_' | '@' ] <non_quote>+ }
    token chord_or_text { '"' [ <chord> | <text_expression> ] [ <chord_newline> [ <chord> | <text_expression> ] ]* '"' }
    
    token element { <broken_rhythm> | <stem> | <rest> | <tuplet> | <slur_begin> | <slur_end> 
                    | <multi_measure_rest>
                    | <gracing> | <grace_notes> | <nth_repeat> | <end_nth_repeat>
                    | <spacing> | <inline_field> | <chord_or_text> }
    
    token barline { '||' | '|]' | ':|:' | '|:' | '|' | ':|' | '::' | '||:' | '&' }
    
    token bar { <element>+ <barline>? }
        
    token line_of_music { <barline>? <bar>+ '\\'? <comment>? $$ }
    
    token interior_header_field_name { < K M L w > }
    token interior_header_field_data { <-[ % \v ]>* }
    token interior_header_field { ^^ <interior_header_field_name> ':' \h* <interior_header_field_data> <comment>? $$ }

    token music { [[<line_of_music> | <interior_header_field> | <comment_line> ] \s*]+ }
    
    token tune { <header> <music> }
    
    token tune_file { \s* [<tune> \s*]+ }
    
    token clef { [ ["clef=" [<clef-note> | <clef-name>]] | <clef-name>] <clef-line>? ["+8" | "-8"]? [\h+ "octave=" <clef-octave>]? [\h+ <clef-middle>]? }
    token clef-note { "G" | "C" | "F" | "P" }
    token clef-name { "treble" | "alto" | "tenor" | "baritone" | "bass" | "mezzo" | "soprano" | "perc" | "none" }
    token clef-line { <[1..5]> }
    token clef-octave { ['+' | '-']? \d+ }
    token clef-middle { "middle=" <basenote> <octave> }

    token key { [ [<key-def> [\h+ <clef>]?] | <clef> | "HP" | "Hp" ] \h* }
    token key-def { <basenote> <chord_accidental>? <mode>? [\h+ <global-accidental>]* }
    token mode { <minor> | <major> | <lydian> | <ionian> | <mixolydian> | <dorian> | <aeolian> | <phrygian> | <locrian> }
    token minor { "m" ["in" ["o" ["r"]?]?]? } # m, min, mino, minor - all modes are case insensitive
    token major { "maj" ["o" ["r"]?]? }
    token lydian { "lyd" ["i" ["a" ["n"]?]?]? } # major with sharp 4th
    token ionian { "ion" ["i" ["a" ["n"]?]?]? } # =major
    token mixolydian { "mix" ["o" ["l" ["y" ["d" ["i" ["a" ["n"]?]?]?]?]?]?]? } # major with flat 7th
    token dorian { "dor" ["i" ["a" ["n"]?]?]? } # minor with sharp 6th
    token aeolian { "aeo" ["l" ["i" ["a" ["n"]?]?]?]? } # =minor
    token phrygian { "phr" ["y" ["g" ["i" ["a" ["n"]?]?]?]?]? } # minor with flat 2nd
    token locrian { "loc" ["r" ["i" ["a" ["n"]?]?]?]? } # minor with flat 2nd and 5th
    token global-accidental { <accidental> <basenote> } # e.g. ^f =c _b
}

sub header_hash($header_match) #OK
{
    gather for $header_match<header_field>
    {
        take $_.<header_field_name>.Str => $_.<header_field_data>.Str;
    }
}

