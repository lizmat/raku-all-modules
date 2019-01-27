unit module Text::More:auth<github:tbrowder>;

# file:  ALL-SUBS.md
# title: Subroutines Exported by the `:ALL` Tag

# export a debug var for users
our $DEBUG is export(:DEBUG) = False;
BEGIN {
    if %*ENV<TEXT_MORE_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

#------------------------------------------------------------------------------
# Subroutine: count-substrs
# Purpose : Count instances of a substring in a string
# Params  : String, Substring
# Returns : Number of substrings found
sub count-substrs(Str:D $ip, Str:D $substr --> UInt) is export(:count-substrs) {
    my $nsubstrs = 0;
    my $idx = index $ip, $substr;
    while $idx.defined {
	++$nsubstrs;
	$idx = index $ip, $substr, $idx+1;
    }

    return $nsubstrs;

} # count-substrs

#------------------------------------------------------------------------------
# Subroutine: strip-comment
# Purpose : Strip comments from an input text line
# Params  : String of text, comment char ('#' is default)
# Returns : String of text with any comment stripped off. Note that the designated char will trigger the strip even though it is escaped or included in quotes.
sub strip-comment(Str $line is copy, Str $comment-char = '#' --> Str) is export(:strip-comment) {
    my $idx = index $line, $comment-char;
    if $idx.defined {
	return substr $line, 0, $idx;
    }
    return $line;
} # strip-comment

#------------------------------------------------------------------------------
# Subroutine: commify
# Purpose : Add commas to a mumber to separate multiples of a thousand
# Params  : An integer or number with a decimal fraction
# Returns : The input number with commas added, e.g., 1234.56 => 1,234.56
sub commify($num) is export(:commify) {
    # translated from Perl Cookbook, 2e, Recipe 2.16
    say "DEBUG: input '$num'" if $DEBUG;
    my $text = $num.flip;
    say "DEBUG: input flipped '$text'" if $DEBUG;
    #$text =~ s:g/ (\d\d\d)(?=\d)(?!\d*\.)/$0,/; # how to do in Perl 6?

    $text ~~ s:g/ (\d\d\d) <?before \d> <!before \d*\.> /$0,/;

    # don't forget to flip back to the original
    $text .= flip;
    say "DEBUG: commified output '$text'" if $DEBUG;

    return $text;

} # commify

#------------------------------------------------------------------------------
# Subroutine: write-paragraph
# Purpose : Wrap a list of words into a paragraph with a maximum line width (default: 78) and update the input list with the results
# Params  : List of words, max line length, paragraph indent, first line indent, pre-text
# Returns : List of formatted paragraph lines
multi write-paragraph(@text,
		      UInt :$max-line-length = 78,
                      UInt :$para-indent = 0,
		      UInt :$first-line-indent = 0,
                      Str :$pre-text = '' --> List) is export(:write-paragraph) {

    #say "DEBUG: text = '@text'" if $DEBUG;
    # calculate the various effective indents and any pre-text effects
    # get the effective first-line indent
    my $findent = $first-line-indent ?? $first-line-indent !! $para-indent;
    # get the effective paragraph indent
    my $pindent = $pre-text.chars + $para-indent;

    my $findent-spaces = ' ' x $findent;
    # ready to take care of the first line
    my $first-line = $pre-text ~ $findent-spaces;
    my $line = $first-line;

    # now do a length check
    {
        my $nc = $line.chars;
        if $nc > $max-line-length {
            say "FATAL:  Line length too long ($nc), must be <= \$max-line-length ($max-line-length)";
            say "line:   '$line'";
            die "length: $nc";
        }
    }

    # get all the words
    my @words = (join ' ', @text).words;

    my @para = ();
    my $first-word = True;
    loop {
        if !@words.elems {
            @para.push: $line if $line;
            #@para.push: $line;
            last;
        }

        my $next = @words[0];
        $next = ' ' ~ $next if !$first-word;
        $first-word = False;

        # do a length check
	{
            my $nc = $next.chars;
            if $nc > $max-line-length {
                say "FATAL:  Line length too long ($nc), must be <= \$max-line-length ($max-line-length)";
                say "line:   '$next'";
                die "length: $nc";
            }
        }

        if $next.chars + $line.chars <= $max-line-length {
            $line ~= $next;
            shift @words;
            next;
        }

        # we're done with this line
        @para.push: $line if $line;
        #@para.push: $line;
        last;
    }

    # and remaining lines
    my $pindent-spaces = ' ' x $pindent;
    $line = $pindent-spaces;
    $first-word = True;
    loop {
        if !@words.elems {
            @para.push: $line if $line;
            #@para.push: $line;
            last;
        }

        my $next = @words[0];
        $next = ' ' ~ $next if !$first-word;
        $first-word = False;

        # do a length check
	{
            my $nc = $next.chars;
            if $nc > $max-line-length {
                say "FATAL:  Line length too long ($nc), must be <= \$max-line-length ($max-line-length)";
                say "line:   '$next'";
                die "length: $nc";
            }
        }

        if $next.chars + $line.chars <= $max-line-length {
            $line ~= $next;
            shift @words;
            next;
        }

        # we're done with this line
        @para.push: $line if $line;
        #@para.push: $line;

        last if !@words.elems;

        # replenish the line
        $line = $pindent-spaces;
        $first-word = True;
    }

    return @para;

} # write-paragraph

#------------------------------------------------------------------------------
# Subroutine: write-paragraph
# Purpose : Wrap a list of words into a paragraph with a maximum line width (default: 78) and print it to the input file handle
# Params  : Output file handle, list of words, max line length, paragraph indent, first line indent, pre-text
# Returns : Nothing
multi write-paragraph($fh, @text,
                      UInt :$max-line-length = 78,
                      UInt :$para-indent = 0,
                      UInt :$first-line-indent = 0,
                      Str :$pre-text = '') is export(:write-paragraph2) {

    # do the mods for the para text
    my @para = write-paragraph(@text, :$max-line-length, :$para-indent, :$first-line-indent, :$pre-text);

    # write to the open file handle
    $fh.say($_) for @para;
}

#------------------------------------------------------------------------------
# Subroutine: normalize-string
# Purpose : Trim a string and collapse multiple whitespace characters to single ones
# Params  : The string to be normalized
# Returns : The normalized string
sub normalize-string(Str:D $str is copy --> Str) is export(:normalize-string) {
    $str .= trim;
    $str ~~ s:g/ \s ** 2..*/ /;
    return $str;
} # normalize-string

#------------------------------------------------------------------------------
# Subroutine: split-line
# Purpose : Split a string into two pieces
# Params  : String to be split, the split character, maximum length, a starting position for the search, search direction
# Returns : The two parts of the split string; the second part will be empty string if the input string is not too long
sub split-line(Str:D $line is copy, Str:D $brk, UInt :$max-line-length = 0,
               UInt :$start-pos = 0, Bool :$rindex = False --> List) is export(:split-line) {
    my $line2 = '';
    return ($line, $line2) if $max-line-length && $line.chars <= $max-line-length;

    my $idx;
    if $rindex {
        my $spos = max $start-pos, $max-line-length;
        $idx = $spos ?? rindex $line, $brk, $spos !! rindex $line, $brk;
    }
    else {
        $idx = $start-pos ?? index $line, $brk, $start-pos !! index $line, $brk;
    }
    if $idx.defined {
        $line2 = substr $line, $idx+1;
        $line  = substr $line, 0, $idx+1;

        #$line  .= trim-trailing;
        #$line2 .= trim;
    }
    return ($line, $line2);

} # split-line

#------------------------------------------------------------------------------
# Subroutine: split-line-rw
# Purpose : Split a string into two pieces
# Params  : String to be split, the split character, maximum length, a starting position for the search, search direction
# Returns : The part of the input string past the break character, or an empty string (the input string is modified in-place if it is too long)
sub split-line-rw(Str:D $line is rw, Str:D $brk, UInt :$max-line-length = 0,
                  UInt :$start-pos = 0, Bool :$rindex = False --> Str) is export(:split-line-rw) {
    my $line2 = '';
    return $line2 if $max-line-length && $line.chars <= $max-line-length;

    my $idx;
    if $rindex {
        my $spos = max $start-pos, $max-line-length;
        $idx = $spos ?? rindex $line, $brk, $spos !! rindex $line, $brk;
    }
    else {
        $idx = $start-pos ?? index $line, $brk, $start-pos !! index $line, $brk;
    }
    if $idx.defined {
        $line2 = substr $line, $idx+1;
        $line  = substr $line, 0, $idx+1;

        #$line  .= trim-trailing;
        #$line2 .= trim;
    }
    return $line2;

} # split-line-rw
