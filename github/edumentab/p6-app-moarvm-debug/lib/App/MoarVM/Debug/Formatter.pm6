unit module MoarVM::Remote::CLI::Formatter;

my $has-color = (try require Terminal::ANSIColor) !=== Nil;
my $wants-color = $*OUT.t;

our sub wants-color is rw is export {
    $wants-color
}

our sub has-color is export {
    $has-color
}

our sub colorstrip(Str() $text) is export {
    if $has-color {
        Terminal::ANSIColor::EXPORT::DEFAULT::colorstrip($text)
    } else {
        $text
    }
}

our sub strlen(Str() $what) is export {
    if $has-color {
        Terminal::ANSIColor::EXPORT::DEFAULT::colorstrip($what).chars;
    } else {
        $what.chars;
    }
}

our sub colored(Str() $what, $how) is export {
    if $has-color && $wants-color {
        Terminal::ANSIColor::EXPORT::DEFAULT::colored($what, $how);
    } else {
        $what
    }
}

our sub bold($what) is export {
    colored($what, "bold");
}
our sub format-attributes($lex-or-attr) is export {
    flat "concrete" xx ?$_<concrete>,
         "container" xx ?$_<container>,
         "value: {$_<value>//""}" xx ($_<value>:exists)
            given $lex-or-attr;
}

our sub format-lexicals-for-frame($lexicals, :@handles-seen) is export {
    gather for $lexicals.kv -> $n, $/ {
        my @attributes = format-attributes($/);

        @handles-seen.push($<handle>.Int) if $<handle> && defined @handles-seen;

        take bold($<handle> // ""), $<type> || $<kind>, $n, @attributes.join(", ");
    }.sort({+colorstrip(.[0])}).cache
}

our sub format-backtrace(@backtrace) is export {
    @backtrace.map({ ($++, .<type>, .<name> || "<anon>", "$_.<file>:$_.<line>", .<bytecode_file> // "none") }).cache
}

our sub print-table(@chunks is copy, :%abbreviated, :%reverse-abbreviated, :$abbreviate-length) is export {
    sub abbreviate(Str() $text is copy) {
        if !defined %abbreviated or !defined $abbreviate-length {
            return $text;
        }
        state $wordlist;
        if strlen($text) > $abbreviate-length {
            my $key;
            $wordlist //= do {
                (try "/usr/share/dict/words".IO.lines().cache)
                || (
                    gather loop {
                        given flat((<b c d f g h j k l m n p q r s t v w x z>.pick((1,1,1,2).pick).Slip,
                        <a e i o u y>.pick((1,2).pick).Slip) xx (1,1,1,2,2).pick).join("") {
                            take $_ if $_.chars > 3;
                        }
                    }
                ).unique[^100].cache
            };
            my @wordcount = flat 1 xx 20, 2 xx 40, 3 xx 100, 4 xx 100, 5 xx 100, 6 xx 100, 7 xx 100, 8 xx 100, 9 xx 100;
            if defined %reverse-abbreviated and (%reverse-abbreviated{$text}:exists) {
                $key = %reverse-abbreviated{$text};
            } else {
                repeat {
                    $key = $wordlist.pick(@wordcount.shift)>>.lc.join("-");
                } while %abbreviated{$key}:exists;
                %abbreviated{$key} = $text;
                %reverse-abbreviated{$text} = $key with %reverse-abbreviated;
            }
            $text .= &colorstrip;
            my $ot = $text;
            $text = $text.lines()[0];
            my $abbrevkey = "... $ot.chars() chars, $ot.lines().elems() lines, key: $key";
            $text.substr-rw($text.chars min ($abbreviate-length - $abbrevkey.chars max 0), *) = $abbrevkey;
        }
        $text;
    }
    my $num-cols = [max] @chunks>>.value.map([max] *>>.elems).flat;
    if $num-cols == -Inf {
        say @chunks.perl;
        try say @chunks[0].key, ": empty.";
        return;
    }
    CATCH {
        .perl.say;
        .perl.say for @chunks;
    }
    my @col-sizes = 0 xx $num-cols;
    for @chunks {
        for .value {
            @col-sizes >>[max]=>> $_>>.&strlen;
        }
    }
    @col-sizes >>min=>> $_ with $abbreviate-length;

    my @result;

    for @chunks -> $chunk {
        @result.push: "\n";
        @result.push: $chunk.key ~ "\n";
        for @($chunk.value) -> $line {
            @result.push: "    ";
            for @$line Z @col-sizes -> ($text, $fieldwidth) {
                @result.push: $text.&abbreviate.&pad($fieldwidth + 2)
            }
            @result.push: "\n";
        }
    }
    say @result.join("");
}

our sub pad(Str() $str, $size) is export {
    my $result = " " x $size;
    $result.substr-rw(0..$str.&strlen) = $str;
    $result;
}

