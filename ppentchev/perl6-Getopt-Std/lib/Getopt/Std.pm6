#!/usr/bin/env perl6

use v6.c;

unit module Getopt::Std:ver<0.1.1.dev1>:auth<github:ppentchev>;

grammar GetoptDefs
{
	token TOP { <options> }
	token options { <option>* }
	token option { <optletter> <optarg>? }
	token optletter { <-[:]> }
	token optarg { ':' }

	class Actions
	{
		method TOP($/) {
			my @opts = $<options>.made;
			my $dup-check = @opts.map(*.key).Bag.grep(*.value > 1).map(*.key).sort.join(', ');
			die "Duplicate option(s) defined: $dup-check" if $dup-check;
			make Hash[Bool:D].new(@opts);
		}

		method options($/) {
			make $<option>».made;
		}

		method option($/) {
			make ~$<optletter> => ?$<optarg>
		}
	}

	method parse(|c)
	{
		nextwith actions => Actions, |c;
	}

	method subparse(|c)
	{
		nextwith actions => Actions, |c;
	}
}

sub getopts-parse-optstring(Str:D $optstr) returns Hash[Bool:D] is export(:util)
{
	my $m = GetoptDefs.parse($optstr);
	die "Could not parse the options string '$optstr'" without $m;
	return $m.made;
}

sub getopts-collapse-array(Bool:D %defs, %opts) is export(:util)
{
	for %opts.kv -> $opt, $value {
		%opts{$opt} = %defs{$opt} || $opt eq chr(1)
		    ?? $value[* - 1]
		    !! $value.join('');
	}
}

sub getopts(Str:D $optstr, %opts, @args, Bool :$all, Bool :$nonopts,
    Bool :$permute, Bool :$unknown) returns Bool:D is export
{
	if $optstr eq '' {
		note 'No options defined';
		return False;
	}
	my Bool:D %defs = getopts-parse-optstring($optstr);

	my Str:D @restore;
	my Bool:D $result = True;
	%opts = ();
	%opts{$_.key}.push($_.value) for gather {
		try {
			while @args {
				my $x = @args.shift;
				if $x eq '--' {
					last;
				} elsif $x !~~ /^ '-' $<opts> = [ .+ ] $/ {
					push @restore, $x;
					if $permute || $nonopts {
						next;
					} else {
						last;
					}
				}
				$x = ~$<opts>;
	
				while $x ~~ /^ $<opt> = [ <[a..zA..Z0..9?]> ] $<rest> = [ .* ] $/ {
					$x = ~$<rest>;
					my Str:D $opt = ~$<opt>;
					if not %defs{$opt}:k {
						die "Invalid option '-$<opt>' specified" unless $unknown;
						take ':' => $opt;
					} elsif !%defs{$opt} {
						take $opt => $opt;
					} elsif $x ne '' {
						take $opt => $x;
						$x = '';
					} elsif @args.elems == 0 {
						die "Option '-$<opt>' requires an argument";
					} else {
						take $opt => @args.shift;
					}
				}
				if $x ne '' {
					die "Invalid option string '$x' specified";
				}
			}
		};
		if $! {
			note ~$!;
			$result = False;
		}
	};

	if $nonopts {
		die "getopts() internal error: arguments left with nonopts: @args.perl()" if @args;
		%opts{chr(1)} = @restore.clone;
	} else {
		@args.unshift(|@restore);
	}
	getopts-collapse-array %defs, %opts unless $all;
	return $result;
}

=begin pod

=head1 NAME

Getopt::Std - Process single-character options with option clustering

=head1 SYNOPSIS

=begin code
    use Getopt::Std;

    # Classical usage, slightly extended:
    # - for options that take an argument, return only the last one
    # - for options that don't, return a string containing the option
    #   name as many times as the option was specified

    my Str:D %opts;
    usage() unless getopts('ho:V', %opts, @*ARGS);

    version() if %opts<V>;
    usage(True) if %opts<h>;
    exit(0) if %opts{<V h>}:k;

    my $outfile = %opts<o> // 'a.out';

    # "All options" usage:
    # - for options that take an argument, return an array of all
    #   the arguments supplied if specified more than once
    # - for options that don't, return the option name as many times
    #   as it was specified

    my Array[Str:D] %opts;
    usage() unless getopts('o:v', %opts, @*ARGS, :all);

    $verbose_level = %opts<v>.elems;

    for %opts<o> -> $fname {
        process_outfile $fname;
    }

    # Permute usage (with both :all and :!all):
    # - don't stop at the first non-option argument, look for more
    #   arguments starting with a dash
    # - stop at an -- argument

    my Str:D %opts;
    usage() unless getopts('ho:V', %opts, @*ARGS, :permute);
=end code

=head1 DESCRIPTION

This module exports the C<getopts()> function for parsing command-line
arguments similarly to the POSIX getopt(3) standard C library routine.

The options are single letters (no long options) preceded by a single
dash character.  Options that do not accept arguments may be clustered
(e.g. C<-hV> for C<-h> and C<-V>); the last one may be an option that accepts
an argument (e.g. C<-vo outfile.txt>).  Options that accept arguments may
have their argument "glued" to the option or in the next element of
the arguments array, i.e. C<-ooutfile> is equivalent to C<-o outfile>.
There is no equals character between an option and its argument; if one is
supplied, it will be considered the first character of the argument.

If an unrecognized option character is supplied in the arguments array,
C<getopts()> will display an error message and return false.  Otherwise
it will return true and fill in the C<%opts> hash with the options found
in the arguments array.  The key in the C<%opts> array is the option name
(e.g. C<h> or C<o>); the value is the option argument for options that
accept one or the option name (as many times as it has been specified) for
options that do not.

=head1 FUNCTIONS

=begin item1
sub getopts

    sub getopts(Str:D $optstr, %opts, @args, Bool :$all, Bool :$nonopts,
      Bool :$permute, Bool :$unknown) returns Bool:D

Look for the command-line options specified in C<$optstr> in the C<@args>
array.  Record the options found into the C<%opts> hash, leave only
the non-option arguments in the C<@args> array.

The C<:all> flag controls the behavior in the case of the same option
specified more than once.  Without it, options that take arguments have
only the last argument recorded in the C<%opts> hash; with the C<:all>
flag, all C<%opts> values are arrays containing all the specified
arguments.  For example, the command line R<-vI foo -I bar -v>, matched
against an option string of R<I:v>, would produce C<{ :I<bar> :v<vv> }>
without C<:all> and C<{ :I(['foo', 'bar']) :v(['v', 'v']) }> with C<:all>.

The C<:permute> flag specifies whether option parsing should stop at
the first non-option argument, or go on and process any other arguments
starting with a dash.  A double dash (R<-->) stops the processing in
this case, too.

The C<:unknown> flag controls the handling of unknown options - ones not
specified in the C<$optstr>, but present in the C<@args>.  If it is
false (the default), C<getopts()> will output an error message and
return false; otherwise, the unknown option character will be present in
the result C<%opts> as an argument to a C<:> option and C<getopts()> will
still return true.  This is similar to the behavior of some C<getopt(3)>
implementations if C<$optstr> starts with a C<:> character.

The C<:nonopts> flag makes C<getopts()> treat each non-option argument as
an argument to an option with a character code 1.  This is similar to
the behavior of some C<getopt(3)> implementations if C<$optstr> starts
with a C<-> character.  The C<:permute> flag is redundant if C<:nonopts>
is specified since the processing will not stop until the arguments array
has been exhausted.

Return true on success, false if an invalid option string has been
specified or an unknown option has been found in the arguments array.

Current API available since version 0.1.0.
=end item1

=begin item1
sub getopts-collapse-array

    sub getopts-collapse-array(Bool:D %defs, %opts)

This function is only available with a C<:util> import.

Collapse a hash of option arrays as returned by C<getopts(:all)> into 
a hash of option strings as returned by C<getopts(:!all)>.  Replace
the value of non-argument-taking options with a string containing
the option name as many times as it was specified, and the value of
argument-taking options with the last value supplied on the command line.
Intended for C<getopts()> internal use and testing.

Current API available since version 0.1.0.
=end item1

=begin item1
sub getopts-parse-optstring

    sub getopts-parse-optstring(Str:D $optstr) returns Hash[Bool:D]

This function is only available with a C<:util> import.

Parse a C<getopts()> option string and return a hash with the options
as keys and whether the respective option expects an argument as values.
Intended for C<getopts()> internal use and testing.

Current API available since version 0.1.0.
=end item1

=head1 AUTHOR

Peter Pentchev <L<roam@ringlet.net|mailto:roam@ringlet.net>>

=head1 COPYRIGHT

Copyright (C) 2016  Peter Pentchev

=head1 LICENSE

The Getopt::Std module is distributed under the terms of
the Artistic License 2.0.  For more details, see the full text of
the license in the file LICENSE in the source distribution.

=end pod
