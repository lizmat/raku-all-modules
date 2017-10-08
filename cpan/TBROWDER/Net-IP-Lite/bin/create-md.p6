#!/usr/bin/env perl6

use Getopt::Std;

my $max-line-length = 78;

##### option handling ##############################
my %opts; # Getopts::Std requires this (name it anything you want)
my ($mfil, $odir, $nofold, $debug, $verbose);
my $usage = "Usage: $*PROGRAM -m <file> | -h[elp] [-d <odir>, -N, -M <max>, -D]";
sub usage() {
   print qq:to/END/;
   $usage

   Reads the input module file and extracts properly formatted
   comments into markdown files describing the subs and other objects
   contained therein.  Output files are created in the output
   directory (-d <dir>) if entered, or the current directory
   otherwise.

   Subroutine signature lines are folded into a nice format for the
   markdown files unless the user uses the -N (no-fold) option.  The
   -M <max> option specifies a user-desired maximum line length for
   folding.

   For an example, the markdown files in the docs directory
   in this repository were created with this program.

   Modes:

     -m <module file>
     -h help

   Options:

     -d <output directory>    default: current directory
     -M <max line length>     default: $max-line-length

     -N do NOT format or modify sub signature lines to max length
     -v verbose
     -D debug
   END

   exit;
}

# provide a short msg if no args
if !@*ARGS {
    say $usage;
    exit;
}
# check for proper getopts signature
usage() if !getopts(
    'hfDv' ~ 'm:d:M:',  # option string (':' following an arg means a value for the arg is required)
    %opts,
    @*ARGS
);
# error check: %opts must exist
#usage() if !%opts;
usage() if %opts<h>;
# check mandatory args
#usage() if !%opts<m>;
$mfil  = %opts<m>;

# set options
$odir            = %opts<d> ?? %opts<d> !! '';
$max-line-length = %opts<M> if %opts<M>;
$debug           = True if %opts<D>;
$verbose         = True if %opts<v>;
$nofold          = True if %opts<N>;
##### end option handling ##########################

# aliases
my $modfil = $mfil;
my $tgtdir = $odir;

my %kw = [
    'Subroutine' => '###',
    'Purpose'    => '-',
    'Params'     => '-',
    'Returns'    => '-',

    'title:'     => '#',

    'file:'      => '',
];

say %kw.perl if $debug;

my %mdfils;
create-md($modfil);
say %mdfils.perl if $debug;


my @ofils;
for %mdfils.keys -> $f is copy {
    # distinguish bewteen file base name and path
    my $of = $f;
    $of = $tgtdir ~ '/' ~ $of if $tgtdir;
    push @ofils, $of;
    my $fh = open $of, :w;


    $fh.say: %mdfils{$f}<title>;

    my %hs = %(%mdfils{$f}<subs>);
    my @subs = %hs.keys.sort;
    for @subs -> $s {
        say "sub: $s" if $debug;
        my @lines = @(%hs{$s});
        for @lines -> $line {
            $fh.say: $line;
        }
    }
    $fh.close;
    say "see output file '$f'";
}

#### subroutines ####
sub create-md($f) {
    # %h{$fname}<title> = $title
    #           <subs>{$subname} = @lines

    my $fname;   # current output file name
    my $title;   # current title for the file contents
    my $subname; # current sub name

    # open the desired module file
    my $fp = open $f;
    for $fp.lines -> $line is copy {
        say $line if $debug;
        next if $line !~~ / \S /; # skip empty lines
        # ensure there is a space following any leading '#'
        $line ~~ s/^ \s* '#' \S /^\# /;
        my @words = $line.words;
        my $nw = @words;

        if $line ~~ /^ \s* '#' / {
            next if $nw < 3;
 	    my $kw  = @words[1];
 	    my $val = @words[2];
            say "possible keyword '$kw'" if $debug;
            #say "possible keyword '$kw'";
            next if not %kw{$kw}:exists;
            say "found keyword '$kw'" if $debug;
            # get the actual line to be output
            my $txt = get-kw-line-data(:val(%kw{$kw}), :$kw, :words(@words[1..*]));
            say "text value: '$txt'" if $debug;
            # next action depends on keyword
            if $kw eq 'file:' {
                # start a new file
                $fname = $val;
            }
            elsif $kw eq 'title:' {
                # update the title name
                $title = $txt;
                %mdfils{$fname}<title> = $title;
            }
            elsif $kw eq 'Subroutine' {
                # update the subroutine name
                $subname = $val;
                # start a new array
                %mdfils{$fname}<subs>{$subname} = [];
                %mdfils{$fname}<subs>{$subname}.push($txt);
            }
            else {
                # all other lines go onto the array
                %mdfils{$fname}<subs>{$subname}.push($txt);
            }
        }
        elsif $line ~~ /^ sub \s* / {
            # start sub signature
            say "found sub sig '$line'" if $debug;
            my @sublines;
            # get the whole signature
            while $line !~~ / '{' / {
                # not the end of signature
                @sublines.push: $line;
                $line = $fp.get;
                say "next line: $line" if $debug;
            }
            # don't forget the last chunk with the opening curly brace
            say "=== DEBUG last line sub sig: '$line'" if $debug;
	    # first add a closing '}'
            my $idx = rindex $line, '{';
            if !$idx.defined {
                die "FATAL: unable to find an opening '\{' in sub sig line '$line'";
            }
            $line = substr $line, 0, $idx + 1;
            # add closure after the opening curly to indcate the sub block
            $line ~= '#...}';
	    # finally, add to the sublines array
            @sublines.push: $line;

            if $debug {
                say "=== complete sub sig:";
                for @sublines {
                    say $_;
                }
                say "=== end complete sub sig:";
            }

            # tidy the line into two (or more) lines (unless user declines)
            @sublines = fold-sub-lines(@sublines, $subname) if !$nofold;

            # push lines on the current element
            say "DEBUG: sub sig lines" if $debug;
            # need a line to indicate perl 6 code
            %mdfils{$fname}<subs>{$subname}.push: '```perl6';
            for @sublines -> $line {
                %mdfils{$fname}<subs>{$subname}.push: $line;
                say "  line: '$line'" if $debug;
            }
            # need a line to indicate end of perl 6 code
            %mdfils{$fname}<subs>{$subname}.push: '```';
        }
    }
}

#### subroutines ####
sub fold-sub-lines(@sublines, $subname) returns List {
    # get one long string to start with
    my $sig = join ' ', @sublines;

    # first we break into two lines after the params ')'
    my @lines;
    my $idx = index $sig, ')';
    die "FATAL: unable to find a closing ')' in sub sig '$sig'" if !$idx.defined;

    my $line1 = substr $sig, 0, $idx + 1;
    my $line2 = substr $sig, $idx + 1;
    # error check
    $idx = index $line2, '{#...}';
    if !$idx.defined {
        die "FATAL: unable to find ending '\{#...} ' in sub sig '$sig'";
    }
    # put two spaces leading the second line
    $line2 .= trim;
    $line2 = '  ' ~ $line2;


    @lines.push: $line1;
    @lines.push: $line2;

    # fold lines if they're too long
    my ($maxlen, $maxid) = analyze-line-lengths(@lines);
    if $maxlen > $max-line-length {
        @lines = shorten-sub-sig-lines(@lines);
    }

    # return the folded lines
    say "NOTE:  sub '$subname' lines were folded" if $verbose;
    return @lines;

}

sub shorten-sub-sig-lines(@siglines) returns List {
    # treat the longest line which normally should be the first one
    # we'll first fold the line at the last comma in the param list
    # then we recalc and reanalyze

    my $nl = +@siglines;
    die "FATAL: should have 2 lines but have $nl" if $nl != 2;
    my ($line1, $line2) = @siglines[0..1];

    # new list for folded lines
    my @lines = [];

    # find last comma in param list, if any
    my $idx = rindex $line1, ',';
    if $idx.defined {
	my $line1-a = substr $line1, 0, $idx + 1; # keep the comma on this line
	my $line1-b = substr $line1, $idx + 1;    # take remainder of the line
	$line1-b .= trim;
	#  we want leading whitespace on the second line so it
	# lines up one char past left paren
	my $idx2 = index $line1-a, '(';
	die "FATAL: unexpected missing '(', line: '$line1'" if !$idx2.defined;
	my $spaces = ' ' x $idx2 + 1;
	$line1-b = $spaces ~ $line1-b;
	@lines.push: $line1-a;
	@lines.push: $line1-b;
	@lines.push: $line2;
    }
    else {
	say "FATAL: Don't know how to handle second line as longest";
        die "FATAL: file a bug report";
    }

    # any improvement?
    my ($maxlen, $maxid) = analyze-line-lengths(@lines);
    if $maxlen > $max-line-length {
	say "FATAL: Don't know how to handle these sub lines where line $maxid is too long:";
	for @lines {
	    say $_;
	}
        die "FATAL: file a bug report";
    }

    return @lines;

}

# candidate for a util module
sub analyze-line-lengths(@lines) returns List {
    # returns:
    #   max line length in the input array
    #   the index of the longest line

    # collect stats
    my $nl = +@lines;
    my %nc;
    my $maxlen = 0;
    my $maxid  = 0;
    my $i = 0;
    for @lines -> $line {
        my $m = $line.chars;
        %nc{$i} = $m;
        if $m > $maxlen {;
            $maxlen = $m;
            $maxid  = $i;
        }
    }

    return ($maxlen, $maxid);

} # analyze-line-lengths

# candidate for a util module
sub normalize-string($str) {
    $str ~~ s:g/ \s ** 2..*/ /;
} # normalize-string

sub get-kw-line-data(:$val, :$kw, :@words is copy) returns Str {
    say "TOM FIX THIS TO HANDLE EACH KEYWORD PROPERLY" if $debug;
    say "DEBUG: reduced \@words array" if $debug;
    say @words.perl if $debug;

    my $txt = '';
    given $kw {
        when 'Subroutine' {
            # pass back just the sub name with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ @words[1];
            # add a leading newline to provide spacing between
            # the preceding subroutine
            $txt = "\n" ~ $txt;
        }
        when 'Purpose'    {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
        when 'Params'     {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
            # need an extra space to prettify the total appearance
            $txt ~~ s/Params/Params /;
        }
        when 'Returns'    {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
        when 'file:'      {
            # don't need anything special
        }
        when 'title:'     {
            # pass back all with leading markup
            $txt ~= $val if $val;
            $txt ~= ' ' ~ join ' ', @words;
        }
    }

    return $txt;
}
