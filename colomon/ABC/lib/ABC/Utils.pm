use v6;
use ABC::Grammar;
use ABC::Context;
use ABC::Note;

package ABC::Utils {
    sub str-to-stem($note) is export {
        my $match = ABC::Grammar.parse($note, :rule<stem>, :actions(ABC::Actions.new));
        $match.ast;
    }
    
    sub element-to-str($element-pair) is export { 
        given $element-pair.key {
            when "gracing" {
                given $element-pair.value {
                    when '.' | '~' { $element-pair.value; }
                    '+' ~ $element-pair.value ~ '+';
                }
            }
            when "inline_field" { '[' ~ $element-pair.value.key ~ ':' ~ $element-pair.value.value ~ ']'; }
            when "chord_or_text" { 
                $element-pair.value.for({
                    when Str { '"' ~ $_ ~ '"'; }
                    ~$_; 
                }).join('') ; 
            }
            when "endline" { "\n"; }
            when "nth_repeat" { 
                $element-pair.value ~~ Set ?? "[" ~ $element-pair.value.keys.join(",")
                                           !! "[" ~ $element-pair.value.perl;
            }
            ~$element-pair.value;
        }
    }


    sub apply_key_signature(%key_signature, $pitch) is export
    {
        my $resulting_note = "";
        if $pitch<accidental>
        {
            $resulting_note ~= $pitch<accidental>.Str;
        }
        else
        {
            if %key_signature{$pitch<basenote>.uc}:exists {
                $resulting_note ~= %key_signature{$pitch<basenote>.uc};
            }
        }
        $resulting_note ~= $pitch<basenote>.Str;
        $resulting_note ~= $pitch<octave>.Str if $pitch<octave>;
        return $resulting_note;
    }

    sub is-a-power-of-two($n) is export {
        if $n ~~ Rat {
            is-a-power-of-two($n.numerator) && is-a-power-of-two($n.denominator);
        } else {
            !($n +& ($n - 1));
        }
    }

    my %notename-to-ordinal = (
        C => 0,
        D => 2,
        E => 4,
        F => 5,
        G => 7,
        A => 9,
        B => 11,
        c => 12,
        d => 14,
        e => 16,
        f => 17,
        g => 19,
        a => 21,
        b => 23
    );
    
    sub to-note-and-number($basenote, $octave-symbol) is export {
        my $octave = $basenote ~~ /<[A..G]>/ ?? 5 !! 6;
        for $octave-symbol.comb {
            when "," { $octave-- }
            when "'" { $octave++ }
        }
        ($basenote.uc, $octave);
    }

    sub from-note-and-number($basenote, $octave-number) is export {
        if $octave-number <= 5 {
            ($basenote.uc, "," x (5 - $octave-number));
        } else {
            ($basenote.lc, "'" x ($octave-number - 6))
        }
    }

    sub pitch-to-ordinal(%key, $accidental, $basenote, $octave) is export {
        my $ord = %notename-to-ordinal{$basenote};
        given $accidental || %key{$basenote.uc} || "" {
            when /^ "^"+ $/ { $ord += $_.chars; }
            when /^ "_"+ $/ { $ord -= $_.chars; }
        }
        given $octave {
            when /^ "'"+ $/ { $ord += $_.chars * 12}
            when /^ ","+ $/ { $ord -= $_.chars * 12}
            when "" { }
            die "Unable to recognize octave $octave";
        }
        $ord;
    }

    sub ordinal-to-pitch(%key, $basenote, $ordinal) is export {
        my $octave = 0;
        my $working-ordinal = %notename-to-ordinal{$basenote.uc};
        while $ordinal + 5 < $working-ordinal {
            $working-ordinal -= 12;
            $octave -= 1;
        }
        while $working-ordinal + 5 < $ordinal {
            $working-ordinal += 12;
            $octave += 1;
        }
        
        my $key-accidental = %key{$basenote.uc} || "=";
        my $working-accidental;
        given $ordinal - $working-ordinal {
            when -2 { $working-accidental = "__"; }
            when -1 { $working-accidental = "_"; }
            when 0  { $working-accidental = "="; }
            when 1  { $working-accidental = "^"; }
            when 2  { $working-accidental = "^^"; }
            die "Too far away from note: $ordinal vs $working-ordinal";
        }
        if $key-accidental eq $working-accidental {
            $working-accidental = "";
        }
        if $octave > 0 {
            ($working-accidental, $basenote.lc, "'" x ($octave - 1));
        } else {
            ($working-accidental, $basenote.uc, "," x -$octave);
        }
    }

    sub stream-of-notes($tune) is export {
        my $key = $tune.header.get-first-value("K");
        my $meter = $tune.header.get-first-value("M");
        my $length = $tune.header.get-first-value("L") // "1/8";
    
        my $context = ABC::Context.new($key, $meter, $length);
        my @elements = $tune.music;
        
        my $repeat-position = 0;
        my $repeat-context = ABC::Context.new($context);
        my $repeat-count = 1;
        my $in-nth-repeat = False;
        my $i = 0;
        gather while ($i < @elements) {
            given @elements[$i].key {
                when "stem" {
                    my $stem = @elements[$i].value;
                    take ABC::Note.new($context.working-accidental($stem),
                                       $stem.basenote, 
                                       $stem.octave,
                                       $stem, 
                                       $stem.is-tie);
                }
                when "tuplet" {
                    my $tuplet = @elements[$i].value;
                    for $tuplet.notes -> $note {
                        take ABC::Note.new($context.working-accidental($note),
                                           $note.basenote,
                                           $note.octave,
                                           ABC::Duration.new(:ticks(2 / $tuplet.tuple * $note.ticks)),
                                           $note.is-tie);
                    }
                }
                when "broken_rhythm" {
                    my $br = @elements[$i].value;
                    for ($br.effective-stem1, $br.effective-stem2) -> $stem {
                        take ABC::Note.new($context.working-accidental($stem),
                                           $stem.basenote, 
                                           $stem.octave,
                                           $stem, 
                                           $stem.is-tie);
                    }
                }
                when "nth_repeat" {
                    $in-nth-repeat = True;
                    if $repeat-count !(elem) @elements[$i].value {
                        # this is an ending for some other repeat, skip it
                        $i++ while ($i < @elements 
                                    && !(@elements[$i].key eq "barline"
                                         && @elements[$i].value eq ":|" | ":|:"));
                    }
                }
                when "end_nth_repeat" {
                    $in-nth-repeat = False;
                }
                when "barline" {
                    given @elements[$i].value {
                        when ":|" | ":|:" {
                            if $in-nth-repeat || $repeat-count == 1 {
                                $context = ABC::Context.new($repeat-context);
                                $i = $repeat-position;
                                $repeat-count++;
                            } else {
                                # treat :| as :|: because it is sometimes used as such by mistake
                                $repeat-context = ABC::Context.new($context);
                                $repeat-position = $i;
                                $repeat-count = 1;
                            }
                            $in-nth-repeat = False;
                        }
                        when "|:" {
                            $repeat-context = ABC::Context.new($context);
                            $repeat-position = $i;
                            $repeat-count = 1;
                            $in-nth-repeat = False;
                        }
                    }
                    $context.bar-line;
                }
                when "chord_or_text" { }
                when "spacing" { }
                when "endline" { }
                take @elements[$i].key;
            }
            $i++;
        }
    }

    sub default-length-from-meter($meter) is export {
        if $meter ~~ m{(\d+ '/' \d+)} {
            $0.Rat < 3/4 ?? "1/16" !! "1/8";
        } else {
            "1/8";
        }
    }
}


