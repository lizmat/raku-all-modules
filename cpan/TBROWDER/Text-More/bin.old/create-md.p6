#!/usr/bin/env perl6

# standard for self-documenting a program
#------------------------------------------------------------------------------
# Program: create-md.p6
# Purpose : Create markdown documentation for programs in a github repository
# Help    : Yes

#use Getopt::Std;
use Text::More :ALL;

my $max-line-length = 78;

##### option handling ##############################
my %opts; # Getopts::Std requires this (name it anything you want)
# ensure we have a var for each option
my ($mfil, $bdir, $odir, $nofold, $debug, $verbose);

my $prog = 'create-md.p6';
my $usage = "Usage: $prog -m <file> | -b <bin dir> | -h [-d <odir>, -N, -M <max>, -D]";

sub usage() {
   print qq:to/END/;
   $usage

   Reads the input module (or program files in the bin dir) and
   extracts properly formatted comments into markdown files describing
   the subs and other objects contained therein.  Output files are
   created in the output directory (-d <dir>) if entered, or the
   current directory otherwise.

   Subroutine signature lines are folded into a nice format for the
   markdown files unless the user uses the -N (no-fold) option.  The
   -M <max> option specifies a user-desired maximum line length for
   folding.  The signature is output as a code block.

   In program files, the comments are folded into lines no longer than
   the maximum line length.  If the program has a help option (-h),
   the result of that command will be added to the output as a code
   block.

   See the lib/Text and bin directories for a module file and a program with the
   known formats.  The markdown files in the docs directory in this
   repository were created with this program from those files.

   Modes (select one only):

     -m <module file>
     -b <bin directory>
     -h help

   Options:

     -d <output directory>    default: current directory
     -M <max line length>     default: $max-line-length

     -N do NOT format or modify sub signature lines to max length
     -v verbose
     -D debug
   END

   #say %opts.perl;

   exit;
}

# provide a short msg if no args
if !@*ARGS.elems {
    say $usage;
    exit;
}

=begin comment
# collect the options
getopts(
    'hDvN' ~ 'b:m:d:M:',  # option string (':' following an arg means a value for the arg is required)
    %opts,
    @*ARGS
);
=end comment

# help overrides all
usage() if %opts<h>;

# set options
$odir            = %opts<d> ?? %opts<d> !! '';
$max-line-length = %opts<M> if %opts<M>;
$debug           = True if %opts<D>;
$verbose         = True if %opts<v>;
$nofold          = True if %opts<N>;
$bdir            = %opts<b> ?? %opts<b> !! '';
$mfil            = %opts<m> ?? %opts<m> !! '';

# check mandatory args
if !($mfil || $bdir) {
    say "ERROR: No mode was selected.";
    say $usage;
    exit;
}
elsif $mfil && $bdir {
    say "ERROR: Multiple modes were selected.";
    say $usage;
    exit;
}
##### end option handling ##########################

# aliases
my $modfil = $mfil;
my $tgtdir = $odir;
my $bindir = $bdir;

# the following two hashes have values for the leading
# markdown code for the key parts
my %kw = [
    # subroutines
    'Subroutine' => '###',
    'Method'     => '###',
    'Purpose'    => '-',
    'Params'     => '-',
    'Returns'    => '-',

    'title'     => '#',
    'file'      => '',
];

my %kwp = [
    # programs
    'Program'    => '###',
    'Purpose'    => '-',
    'Help'       => '',
];

say %kw.perl if $debug;
say %kwp.perl if $debug;

# HANDLE SUBROUTINES =================================================
my %mdfils;
if $modfil {
    create-subs-md($modfil);
    say %mdfils.perl if $debug;

    my @ofils;
    for %mdfils.keys -> $f is copy {
	# distinguish between file base name and path
	my $of = $f;
	$of = $tgtdir ~ '/' ~ $of if $tgtdir;
	my $fh = open $of, :w;

	$fh.say: %mdfils{$f}<title>;

	my %hs = %(%mdfils{$f}<subs>);
	# keys are nominally the sub name, but may have a number
        # appended in the case of multi-subs
	my @subids = %hs.keys.sort;

        # need to make a TOC
        create-toc-md($fh, 'Contents', @subids, 3, :add-link(True));

	for @subids -> $s {
            say "subid: $s" if $debug;
            my $scope = %hs{$s}<scope>;
            my $sub   = %hs{$s}<name>;

            my @lines = @(%hs{$s}<lines>);

            # the first line is special
            my $first-line = shift @lines;
            my @w = $first-line.words;

            # get rid of the sub name
            pop @w;

            # reassemble the first line
            @w.push: $scope;
            $first-line = join ' ', @w;
            $first-line ~= ' ' ~ $sub;
            $fh.say: $first-line;
            for @lines -> $line {
		$fh.say: $line;
            }
	}
	$fh.close;
        @ofils.push($of);
    }

    my $s = @ofils.elems > 1 ?? 's' !! '';
    say "see output file$s:";
    say "  $_" for @ofils;

}

# HANDLE BINARY PROGS =================================================
my %binfils;
if $bindir {
    create-bin-md($bindir);
    say %binfils.perl if $debug;

    # distinguish between file base name and path
    my $of = 'PROGRAMS.md';
    $of = $tgtdir ~ '/' ~ $of if $tgtdir;
    my $fh = open $of, :w;

    my $title = '# Programs';
    $fh.say: $title;

    my @progs = %binfils.keys.sort;
    # need to make a TOC
    create-toc-md($fh, 'Contents', @progs, 1, :add-link(True));

    for @progs -> $p {
        say "program: $p" if $debug;
        my @lines = @(%binfils{$p});
        for @lines -> $line {
            $fh.say: $line;
        }
    }

    $fh.close;
    say "see output file '$of'";
}

#### subroutines #####
sub create-bin-md($d) {
    # HANDLES PROGRAMS

    # %h{$program} = @lines;

    my $program; # current program name

    # open the bin directory
    my @fils = $d.IO.dir;
    say "Files in dir '$d':";
    for @fils -> $f {
	# for now assume it's a prog (TODO docs show auto finding files, NOT so)
	my $is-file = $f.f ?? True !! False;
	if !$is-file {
	    say "  '$f' is a directory...skipping";
	    next;
	}
	say "  '$f' is a file...processing";

	# open the program file
        my $program;
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
		next if not %kwp{$kw}:exists;
		say "found keyword '$kw'" if $debug;
		# get the actual line to be output
		my $txt = get-kw-line-data(:val(%kwp{$kw}), :$kw, :words(@words[1..*]));
		say "text value: '$txt'" if $debug;
		# next action depends on keyword
		if $kw eq 'Program' {
                    # update the program name
                    $program = $val;
                    # sanity check
                    die "FATAL: File '$f' and prog name '$program' differ" if $f !~~ /$program/;
                    # start a new array
                    %binfils{$program} = [];
                    %binfils{$program}.push($txt);
		}
		else {
                    # all other lines go onto the array
                    %binfils{$program}.push($txt);

                    if $kw eq 'Help' && $val ~~ /:i y/ {
                        # generate the help text
                        say 'TODO: fix this with a sub, add text';
                        %binfils{$program}.push(get-help-lines($f));
                    }
		}
            }

	}

    }

} # create-bin-md

sub get-help-lines($prog) {
    return 'FINISH THE GET HELP SUB';
} # get-help-lines

sub get-multi-id(%mdfils, $fname, $subid is copy) {
    # return a unique id based on the input name and a single digit suffix (2-9)
    # routine will have to be modified if more than 9 multi sub names are needed

    if $debug {
        say "DEBUG in 'get-multi-id'";
        say "  \$subid = '$subid'; \%mdfils:";
        say %mdfils.gist;
    }

    if !%mdfils{$fname}<subs>{$subid} {
        return $subid;
    }

    # we have a duplicate, get the next in line
    my $basename;
    my $n;
    if $subid ~~ /^ (\.*) (\d) $/ {
	$basename = ~$0;
	$n        = +$1;
    }
    else {
        $basename = $subid;
    }

    if $debug {
        say "DEBUG in 'get-multi-id'";
        say "  \$subid = '$subid'; \$basename = '$basename'";
    }

    if !$n.defined {
	# add a 2;
	$n = '2';
	$subid = $basename ~ $n;
	die "FATAL: unexpected existing name '$subid'" if %mdfils{$fname}<subs>{$subid};
	return $subid;
    }

    # more work to do
    while %mdfils{$fname}<subs>{$basename ~ $n} {
        ++$n;
    }
    die "FATAL: need a fix here: \$n = '$n', \$subid = '$subid'" if $n > 9;

    $subid = $basename ~ $n;
    die "FATAL: unexpected existing subid '$subid'" if %mdfils{$fname}<subs>{$subid};
    return $subid;

} # get-multi-id

sub create-subs-md($f) {
    # HANDLES MODULES

    # %h{$fname}<title> = $title
    #           <subs>{$subid}<name>  = $subname
    #           <subs>{$subid}<lines> = @lines
    #           <subs>{$subid}<scope> = $scope # e.g., 'multi sub'

    my $fname;   # current output file name
    my $title;   # current title for the file contents
    my $subid;   # current sub index

    # open the desired module file
    my $fp = open $f;
    my $in-begin = 0;
    for $fp.lines -> $line is copy {
        say $line if $debug;
        next if $line !~~ / \S /; # skip empty lines

        # skip =begin / =end blocks
        if $line ~~ /^ \s* '=begin' / {
            ++$in-begin;
            next;
        }
        if $line ~~ /^ \s* '=end' / {
            --$in-begin;
            die "FATAL: unmatched =begin/=end blocks" if $in-begin < 0;
            next;
        }
        next if $in-begin;

        my $maybe-kwline = 0;
        if $line ~~ /^ \s* '#' / {
            $maybe-kwline = 1;
            # ensure there is a space following any leading '#'
            $line ~~ s/^ \s* '#' /\# /;
            # ensure there is NO space before the first ':'
            $line ~~ s/ \s* ':' /\:/;
            # ensure there is a space following the first ':'
            $line ~~ s/ ':' /\: /;
            say "DEBUG: possible kw line: '$line'" if $debug && $line ~~ /':'/;
        }
        my @words = $line.words;
        my $nw = @words;

        if $maybe-kwline {
            next if $nw < 3;

            my $kw;
            if $line ~~ /^ \s* '#' \s+ (\w+) \s* ':' / {
                $kw = ~$0;
            }
            else {
                next;
            }

            # dump first word which is '#'
            shift @words;
            # dump second word which is the keyword
            shift @words;

            say "possible keyword '$kw'" if $debug;
            next if not %kw{$kw}:exists;

            say "found keyword '$kw'" if $debug;

            # we need the original next word for special uses
            my $orig-val = @words[0];

            # get the actual line to be output
            my $txt = get-kw-line-data(:$kw, :words(@words));
            say "text value: '$txt'" if $debug;

            # next action depends on keyword
            if $kw eq 'file' {
                # start a new file
                $fname = $orig-val;
            }
            elsif $kw eq 'title' {
                # update the file's title name
                $title = $txt;
                %mdfils{$fname}<title> = $title;
            }
            elsif $kw eq 'Subroutine' || $kw eq 'Method' {
                # update the subroutine name (may be a multi name, special handling)
                my $subname = $orig-val;
                $subid = $subname;
                if %mdfils{$fname}<subs>{$subid}:exists {
                    say "CREATE NEW SUB ID FOR MULTI";
                    $subid = get-multi-id(%mdfils, $fname, $subid);
                }

                # start a new sub entry with name and lines array
                %mdfils{$fname}<subs>{$subid}<name>  = $subname;
                %mdfils{$fname}<subs>{$subid}<lines> = [];
                %mdfils{$fname}<subs>{$subid}<lines>.push($txt);
            }
            else {
                # all other lines go onto the array
                %mdfils{$fname}<subs>{$subid}<lines>.push($txt);
            }
        }
        elsif $line ~~ /^ [sub|method|multi] \s* / {
            # start sub signature
            say "found sub sig '$line'" if $debug;

            # get all words in front of sub name
            {
                my $idx = index $line, '(';
                die "FATAL: no '(' found in line '$line'" if !$idx.defined;
                my $s = substr $line, 0, $idx;
                my @w = $s.words;
                pop @w; # get rid of the name
                my $scope = join ' ', @w;
                if 0 && $debug {
                    die "DEBUG: scope = '$scope'";
                }
                # add scope to hash
                %mdfils{$fname}<subs>{$subid}<scope> = $scope;
            }
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
            @sublines = fold-sub-lines(@sublines, $subid) if !$nofold;

            # push lines on the current element
            say "DEBUG: sub sig lines" if $debug;
            # need a line to indicate perl 6 code
            %mdfils{$fname}<subs>{$subid}<lines>.push: '```perl6';
            for @sublines -> $line {
                %mdfils{$fname}<subs>{$subid}<lines>.push: $line;
                say "  line: '$line'" if $debug;
            }
            # need a line to indicate end of perl 6 code
            %mdfils{$fname}<subs>{$subid}<lines>.push: '```';
        }
    }
} # create-subs-md

sub fold-sub-lines(@sublines, $subid --> List) {
    # get one long string to start with
    my $sig = normalize-string(join ' ', @sublines);

    {
	# error checks
	my $idx = index $sig, ')';
	die "FATAL: unable to find a closing ')' in sub sig '$sig'" if !$idx.defined;
	$idx = index $sig, '{#...}';
	die "FATAL: unable to find ending '\{#...}' in sub sig '$sig'" if !$idx.defined;
	$idx = index $sig, '(';
	die "FATAL: unable to find opening '(' in sub sig '$sig'" if !$idx.defined;
    }

    my @lines;

    # ideally we break into two lines after the params ')';
    # note we break regardless of line length at this point
    my ($line1, $last-line) = split-line($sig, ')');
    # indent two spaces on the last line
    $last-line = '  ' ~ $last-line;
    if $last-line.chars > $max-line-length {
        die "UNEXPECTED last line too long: '$last-line'";
    }

    if $line1.chars > $max-line-length {
        my $idx = index $line1, '(';
        my $fold-indent = ' ' x $idx+1;
        my $first-line = True;

        # keep splitting until done
        my @tlines;
        my $s1 = $line1;
        my $s2 = '';

        loop {
            $s2 = split-line-rw($s1, ',', :max-line-length($max-line-length), :rindex(True));
            # $s1 is known good
            #$s1 = $fold-indent ~ $s1 if !$first-line;
            @tlines.push($s1);
            $first-line = False;

            if !$s2 {
                # we're done
                last;
            }

            # add the standard indent to the opening paren
            $s2 = $fold-indent ~ $s2;
            if $s2.chars <= $max-line-length {
                # we're done
                @tlines.push($s2);
                last;
            }

            # need another split
            $s1 = $s2;
            $s2 = '';
        }
        if $debug {
            say "DEBUG: in sub $subid, @tlines:";
            say "  lines:";
            say "    $_" for @tlines;
        }

        @lines.push($_) for @tlines;
    }
    else {
        @lines.push($line1);
    }

    # don't forget the last line!
    @lines.push($last-line);

    # sanity check
    my ($maxlen, $maxidx) = analyze-line-lengths(@lines);
    if $maxlen > $max-line-length {
        say "WARNING: in sub $subid: maxlen = $maxlen, maxidx = $maxidx";
        say "  lines:";
        say "    $_" for @lines;
    }
    # return the folded lines
    say "NOTE:  sub '$subid' lines were folded" if $verbose;
    return @lines;

}

# candidate for a util module
sub analyze-line-lengths(@lines --> List) {
    # returns:
    #   max line length in the input array
    #   the index of the longest line

    # collect stats
    my $nl = +@lines;
    my %nc;
    my $maxlen = 0;
    my $maxidx = 0;
    my $i = 0;
    for @lines -> $line {
        my $m = $line.chars;
        %nc{$i} = $m;
        if $m > $maxlen {;
            $maxlen = $m;
            $maxidx = $i;
        }
        ++$i;
    }

    return ($maxlen, $maxidx);

} # analyze-line-lengths


sub get-kw-line-data(:$kw, :@words is copy --> Str) {
    say "TOM FIX THIS TO HANDLE EACH KEYWORD PROPERLY" if $debug;
    say "DEBUG: reduced \@words array" if $debug;
    say @words.perl if $debug;

    # get the md value of the keyword
    my $md-val = %kw{$kw};

    my $txt = '';
    given $kw {
        when / [Subroutine|Method] / {
            # pass back just the sub name with leading markup
            $txt ~= $md-val if $md-val;
            $txt ~= ' ' ~ @words[0];
            # add a leading newline to provide spacing between
            # the preceding subroutine
            $txt = "\n" ~ $txt;
        }
        when / [Purpose|Params|Returns] /    {
            # pass back all with leading markup
            $txt ~= $md-val if $md-val;
            # for Params need an extra space to prettify the total appearance
            my $s = $kw eq 'Params' ?? $kw ~ ' : ' !! $kw ~ ': ';
            $txt ~= ' ' ~ $s ~ join ' ', @words;
        }
        when 'file' {
            # no handling needed just the text
        }
        when 'title'     {
            # pass back all with leading markup
            $txt ~= $md-val if $md-val;
            $txt ~= ' ' ~ join ' ', @words;
        }
    }

    return $txt;
}

sub create-loc-md($fh, $title, @list is copy, UInt :$nitems = 0,
                  Bool :$add-link = True, UInt :$max-line-length = 78) {
    # note this creates a list of contents, not as pretty as a table,
    # but it doesn't have the mandatory column headings
    my $ne = @list.elems;
    my $nrows = $ne div $nitems;
    ++$nrows if $ne % $nitems; # check for partial rows

    $fh.say: "\n### $title\n";

    for 0..^$nrows {
        for 0..^$nitems {
            my $c = @list.elems ?? @list.shift !! '';
            if $c && $add-link {
                # add the link
                my $link = '#' ~ lc $c;
                $fh.print: "| [$c]($link) ";
            }
            else {
                $fh.print: "| $c ";
            }
        }
        $fh.say: '|';
    }
} # create-loc-md

sub create-toc-md($fh, $title, @list is copy, $ncols, :@headings, :@just, :$add-link) {
    # note this creates a table with a clunky set of column headers which are required
    # due to githubs limited flavor of markdown (I've filed an issue with github
    # and they've acknowledged it [2016-11-04])

    my $ne = @list.elems;
    my $nrows = $ne div $ncols;
    ++$nrows if $ne % $ncols; # check for partial columns

    $fh.say: "\n### $title\n";
    if @headings.elems {
        my $nh = @headings.elems;
        my $nj = @just.elems ?? @just.elems !! 0;

        die "FATAL: \$headings.elems ($nh) not equal to \$ncols ($ncols)" if $nh != $ncols;
        die "FATAL: \$just.elems ($nj) not equal to \$ncols ($ncols)" if $nj && $nj != $ncols;

        # need 2 loops
        # column headings
        for @headings -> $h {
            $fh.print: "| $h ";
        }
        $fh.say: '|';

        # the heading separator row
        for 0..^$ncols -> $i {
            my $b = '---';
            if $nj {
                given @just[$i] {
                    when /:i L/ { $b = ':' ~ $b }
                    when /:i C/ {               } # use the default
		    when /:i R/ { $b ~= ':'     }
                }
            }
            $fh.print: "| $b ";
        }
        $fh.say: '|';
    }
    # note that at the moment github markdown requires column headings
    else {
        # need 2 loops
        # column headings
        for 1..$ncols -> $n {
            $fh.print: "| Col $n ";
        }
        $fh.say: '|';

        # the heading separator row
        for 0..^$ncols -> $i {
            my $b = '---';
            $fh.print: "| $b ";
        }
        $fh.say: '|';
    }

    # add the table content
    for 0..^$nrows {
        for 0..^$ncols {
            my $c = @list.elems ?? @list.shift !! '';
            if $c && $add-link {
                # add the link
                my $link = '#' ~ lc $c;
                $fh.print: "| [$c]($link) ";
            }
            else {
                $fh.print: "| $c ";
            }
        }
        $fh.say: '|';
    }
} # create-toc-md
