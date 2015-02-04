#use Grammar::Tracer;
grammar Text::CSV::File {
    regex TOP { ^ <line>+ % "\n" <empty_line>* $ }
    regex line { <value>+ % ',' }
    regex value {
        <before ','> | <pure_text>
        | [\h* \"] ~ [\" \h*] <quoted_contents>
    }
    regex quoted_contents { [ <pure_text> | ',' | \s | '""' ]* }
    regex pure_text { [<!before <[",]>> \N]+ }
    regex empty_line { \h* \n }
}

class Text::CSV {
    has $.trim;
    has $.strict;
    has $.skip-header;
    has $.output;
    has $.quote;
    has $.separator;

    my $trim-default        = False;
    my $strict-default      = 'default';
    my $skip-header-default = False;
    my $output-default      = 'arrays';
    my $quote-default       = '"';
    my $separator-default   = ',';

    sub extract_text($m, $quote, :$trim) {
        my $text = ($m<quoted_contents> // $m).subst("$quote$quote", $quote, :global);
        return $trim ?? $text.trim !! ~$text;
    }

    method parse($input, :$trim is copy, :$strict is copy,
                         :$skip-header is copy, :$output is copy,
                         :$separator is copy, :$quote is copy) {

        if self.defined {
            $trim        //= $.trim        // $trim-default;
            $strict      //= $.strict      // $strict-default;
            $skip-header //= $.skip-header // $skip-header-default;
            $separator   //= $.separator   // $separator-default;
            $quote       //= $.quote       // $quote-default;
            if $output === Any {
                $output    = $.output      // $output-default;
            }
        }
        else {
            $trim        //= $trim-default;
            $strict      //= $strict-default;
            $skip-header //= $skip-header-default;
            $separator   //= $separator-default;
            $quote       //= $quote-default;
            if $output === Any {
                $output    = $output-default;
            }
        }

        if $output ~~ Str {
            $output = $output.lc;
        }

        if my $check = check_ok($quote, $separator) {
            die $check;
        }

        my $parser = Text::CSV::File;
        if $quote ne $quote-default or $separator ne $separator-default {
            grammar CustomCSV is Text::CSV::File {
                regex line { <value>+ % $separator }
                regex value {
                    <before $separator> | <pure_text> |
                    $quote ~ $quote <quoted_contents>
                }
                regex quoted_contents {
                    [ <pure_text> | $separator | <[\r\n]> |
                      ' ' | $quote$quote ]*
                }
                regex pure_text { [<!before [$quote | $separator]> \N]+ }
            }
            $parser = CustomCSV;
        }
        $parser.parse($input)
            or die "Sorry, cannot parse";
        my @lines = $<line>.list;
        my @values = map {
            [map { extract_text($_, $quote, :$trim) }, .<value>.list]
        }, @lines;
        if $strict eq 'default' {
            $strict = !$output || $output !~~ 'arrays';
        }
        if $strict {
            my $expected-columns = @values[0].elems;
            for ^@values -> $line {
                if (my $c = @values[$line]) > $expected-columns {
                    die "Too many columns ($c, expected $expected-columns) "
                        ~ "on line $line";
                }
                elsif $c < $expected-columns {
                    die "Too few columns ($c, expected $expected-columns) "
                        ~ "on line $line";
                }
            }
        }
        if $output && $output eq 'hashes' {
            my @header = @values.shift.list;
            my @results;
            my $i = 0;
            for @values -> @line {
                my %hash = map { @header[$_] => @line[$_] }, ^(+@line min +@header);
                @results[$i++] = %hash;
            }
            @values = @results;
        }
        elsif $output && $output eq 'arrays' {
            if $skip-header {
                @values.shift;
            }
        }
        else {
            my $type = $output;
            my @header = @values.shift.list;
            @values = map -> @line {
                my %attrs = map {; @header[$_] => @line[$_] },
                            ^(+@line min +@header);
                $type.new( |%attrs );
            }, @values;
        }
        return @values;
    }

    method parse-file($filename, *%_) {
        return self.parse( slurp($filename), |%_ );
    }
}

our sub csv-write ( @csv, :$header = '', :$separator is copy = ',',
                   :$always_quote, :$quote is copy = <"> ) is export {

    if my $check = check_ok($quote, $separator) {
        die $check;
    }
    my @header = $header ?? @$header !! ();
    my $first = @csv[0];
    my @csv-quoted;

    if $first ~~ Array { # AoA
        if @header.elems {
            add( @header );
        }
        for @csv -> $line {
           add( @$line );
        }
    }
    elsif $first ~~ Hash { # AoH
        unless @header.elems {
            die "Can not guarantee order of columns if no header is provided";
        }
        add( @header );
        for @csv -> $line {
           add( %$line{@header} );
        }
    }
    elsif $first ~~ Cool { # Assume it is just an array of strings
        if @header.elems { # A header doesn't make much sense here,
            add( @header); # but it is probably better to allow it
        }
        add( @csv );
    }
    else { # AoO
        unless @header.elems {
            die "You need to provide a header array of accessors";
        }
        add( @header );
        for @csv -> $object {
           @csv-quoted.push: (join $separator, map { csv-quote $object."$_"() }, @header);
        }
    };

    return @csv-quoted.join("\n");

    sub add(@list) {
         @csv-quoted.push: (join $separator, map { csv-quote $_ }, @list);
    }

    sub csv-quote ($str is copy = '') {
        if $always_quote or $str ~~ / $quote | $separator | \r | \n / {
            $str = $quote ~ $str.subst($quote, $quote ~ $quote, :g) ~ $quote;
        }
        $str
    }
}

our sub csv-write-file (@csv, :$file, *%_) is export {
    die "Must provide an output file name" unless $file.defined;
    my $fh = open($file, :w) or die $!;
    $fh.print( csv-write( @csv, |%_ ) );
    $fh.close or die $!;
}

sub check_ok ($quote, $separator) {
    return "Sorry, can not use a space as a quoting character"
      if $quote ~~ /\s/;
    return "Sorry, can not use a newline as a separator character"
      if $separator ~~ /\n/;
    return "Sorry, only single character separators are supported"
      if $separator.chars != 1;
    return "Sorry, only single character quotes are supported"
      if $quote.chars != 1;
    return "Sorry, you can't use the same character for separator AND quote."
      if $quote eq $separator;
}

# vim:ft=perl6
