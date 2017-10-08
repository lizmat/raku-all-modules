unit module Proc::More:auth<github:tbrowder>;

# file:  ALL-SUBS.md
# title: Subroutines Exported by the `:ALL` Tag

# export a debug var for users
our $DEBUG is export(:DEBUG) = False;
BEGIN {
    if %*ENV<PROC_MORE_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

# need some regexes to make life easier
my token typ { ^ :i             # the desired time(s) to return:
                    a|all|      # show all three times:
		                #   "Real: [time in desired format]; User: [ditto]; Sys: [ditto]"
                    r|real|     # show only the real (wall clock) time
                    u|user|     # show only the user time [default]
                    s|sys       # show only the system time
             $ }
my token fmt { ^ :i             # the desired format for the returned time(s) [default: raw seconds]
                    s|seconds|  # time in seconds with an appended 's': "30.42s"
                    h|hms|      # time in hms format: "0h00m30.42s"
                    ':'|'h:m:s' # time in h:m:s format: "0:00:30.42"
             $ }

#------------------------------------------------------------------------------
# Subroutine: read-sys-time
# Purpose : An internal helper function that is not exported.
# Params  : A string that contains output from the GNU 'time' command, and three named parameters that describe which type of time values to return and in what format.
# Returns : A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.
sub read-sys-time($result,
                  :$typ where { $typ ~~ &typ } = 'u',            # see token 'typ' definition
                  :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                  Bool :$list = False,                           # return a list as in the original API
                 ) {

    say "DEBUG: time result '$result'" if $DEBUG;
    # get the individual seconds for each type of time
    my ($Rts, $Uts, $Sts);
    for $result.lines -> $line {
	say "DEBUG: line: $line" if $DEBUG;

	my $typ = $line.words[0];
	my $sec = $line.words[1];
	given $typ {
            when /real/ {
		$Rts = sprintf "%.3f", $sec;
		say "DEBUG: rts: $Rts" if $DEBUG;
            }
            when /user/ {
		$Uts = sprintf "%.3f", $sec;
		say "DEBUG: uts: $Uts" if $DEBUG;
            }
            when /sys/ {
		$Sts = sprintf "%.3f", $sec;
		say "DEBUG: sts: $Sts" if $DEBUG;
            }
            default {
                if $line ~~ /exit|code/ && $line ~~ / (\d+) / {
                    my $exitcode = +$0;
                    die "FATAL: The timed command returned a non-zero exitcode: $exitcode";
                }
            }
	}
    }

    my $res;
    if !$fmt {
        # returning raw seconds
        given $typ {
            when /^ :i a/ {
                $res = "Real: $Rts; User: $Uts; Sys: $Sts";
            }
            when /^ :i r/ {
                $res = $Rts;
            }
            when /^ :i u/ {
                $res = $Uts;
            }
            when /^ :i s/ {
                $res = $Sts;
            }
        }
    }

    if $res.defined {
        if $list {
            # create and return a list
	    # in old system: [RUS]ts is the same, [rus]ts is "<seconds to 2 decimals> ]
            my $rt = seconds-to-hms(+$Rts, :fmt<h>);
            my $ut = seconds-to-hms(+$Uts, :fmt<h>);
            my $st = seconds-to-hms(+$Sts, :fmt<h>);
	    return $Rts, $rt,
                   $Uts, $ut,
                   $Sts, $st;
        }
        else {
            # just return the string
            return $res;
        }
    }

    # returning formatted time
    # convert each to hms or h:m:s

    given $typ {
        when /^ :i a/ {
            my $rt = seconds-to-hms(+$Rts, :$fmt);
            my $ut = seconds-to-hms(+$Uts, :$fmt);
            my $st = seconds-to-hms(+$Sts, :$fmt);
            $res = "Real: $rt; User: $ut; Sys: $st";
        }
        when /^ :i r/ {
            $res = seconds-to-hms(+$Rts, :$fmt);
        }
        when /^ :i u/ {
            $res = seconds-to-hms(+$Uts, :$fmt);
        }
        when /^ :i s/ {
            $res = seconds-to-hms(+$Sts, :$fmt);
        }
	default { die "FATAL: no option found"; }
    }

    if $list {
        # create and return a list
	# in old system: [RUS]ts is the same, [rus]ts is "<seconds to 2 decimals> ]
        my $rt = seconds-to-hms(+$Rts, :fmt<h>);
        my $ut = seconds-to-hms(+$Uts, :fmt<h>);
        my $st = seconds-to-hms(+$Sts, :fmt<h>);
	return $Rts, $rt,
               $Uts, $ut,
               $Sts, $st;
    }
    else {
        # just return the string
        return $res;
    }

} # read-sys-time

#------------------------------------------------------------------------------
# Subroutine: seconds-to-hms
# Purpose : Return input time in seconds (without or with a trailing 's') or convert time in seconds to hms or h:m:s format.
# Params  : Time in seconds.
# Returns : Time in in seconds (without or with a trailing 's') or hms format, e.g, '3h02m02.65s', or h:m:s format, e.g., '3:02:02.65'.
sub seconds-to-hms($Time,
                   :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                   --> Str) is export(:seconds-to-hms) {

    my $time = $Time;

    my UInt $sec-per-min = 60;
    my UInt $min-per-hr  = 60;
    my UInt $sec-per-hr  = $sec-per-min * $min-per-hr;

    my UInt $hr  = ($time/$sec-per-hr).UInt;
    my $sec = $time - ($sec-per-hr * $hr);
    my UInt $min = ($sec/$sec-per-min).UInt;

    $sec = $sec - ($sec-per-min * $min);

    my $ts;
    if !$fmt {
        $ts = ~$time;
    }
    elsif $fmt ~~ /^ :i s/ {
        $ts = sprintf "%.2fs", $sec;
    }
    elsif $fmt ~~ / ':'/ {
        $ts = sprintf "%d:%02d:%05.2f", $hr, $min, $sec;
    }
    elsif $fmt ~~ /^ :i h/ {
        $ts = sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
    }

    return $ts;

} # seconds-to-hms

#------------------------------------------------------------------------------
# Subroutine: time-command
# Purpose : Collect the process times for a system or user command (using the GNU 'time' command).
# Params : The command as a string, and four named parameters that describe which type of time values to return and in what format. Note that special characters are not recognized by the 'run' routine, so results may not be as expected if they are part of the command.
# Returns : A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.
sub time-command(Str:D $cmd,
                 :$typ where { $typ ~~ &typ } = 'u',            # see token 'typ' definition
                 :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
		 :$dir,                                         # run command in dir 'dir'
                 Bool :$list = False,                           # return a list as in the original API
                 Hash() :$env = %*ENV,
                ) is export(:time-command) {
    # runs the input cmd using the system 'run' function and returns
    # the process times shown below

    # look for the time program in several places:
    my $TCMD;
    my $TE = 'PROC_MORE_TIME';
    my @t = <
        /usr/bin/time
        /usr/local/bin
    >;
    if %*ENV{$TE}:exists && %*ENV{$TE}.IO.f {
        $TCMD = %*ENV{$TE};
    }
    else {
        for @t -> $t {
            if $t.IO.f {
                $TCMD = $t;
                last;
            }
        }
    }
    if !$TCMD.defined {
        die "FATAL: The 'time' command was not found on this host.";
    }

    $TCMD ~= ' -p'; # the '-t' option gives the standard POSIX output display

    my $CMD = "$TCMD $cmd";
    my ($exitcode, $stderr, $stdout);
    if $dir {
	($exitcode, $stderr, $stdout) = run-command $CMD, :all, :$env, :$dir;
    }
    else {
	($exitcode, $stderr, $stdout) = run-command $CMD, :all, :$env;
    }
    if $exitcode {
        die qq:to/HERE/;
            FATAL: The '$CMD' command returned a non-zero exitcode: $exitcode
                   stderr: $stderr
                   stdout: $stdout
            HERE
    }
    my $result = $stderr; # the time command puts all output to stderr
    if $fmt.defined {
        return read-sys-time($result, :$typ, :$fmt, :$list);
    }
    else {
        return read-sys-time($result, :$typ, :$list);
    }

} # time-command

#------------------------------------------------------------------------------
# Subroutine: run-command
# Purpose : Run a system command using class Proc.
# Params  : A string that contains a command suitable using Perl 6's run routine, and four named parameters that describe inputs and desired outputs.
# Returns : Either the exit code (default), a list of exit code and results from stderr and stderr, or just the results from stdout.  There is also the capability to send debug messages to stdout.
sub run-command(Str:D $cmd,
                :$err,
		:$out,
		:$all,
		Bool :$debug = False,
		:$dir,                # run command in dir 'dir'
                Hash() :$env = %*ENV,
	       ) is export(:run-command) {
    # default is to return the exit code which should be zero (false) for a successful command execuiton
    # :dir runs the command in 'dir'
    # :all returns a list of three items: exit code, stderr, and stdout
    # :err returns stderr
    # :out returns stdout
    # :debug prints extra info to stdout AFTER the proc command

    my $cwd = $*CWD;
    chdir $dir if $dir;
    #=== may be in another dir ===
    my $proc = run $cmd.words, :err, :out;
    my $exitcode = $proc.exitcode;
    # always need to close file handles if used
    my $stderr   = $proc.err.slurp(:close) if $all || $err;
    my $stdout   = $proc.out.slurp(:close) if $all || $out;
    #=== leave the other dir ===
    chdir $cwd if $dir;

    if $exitcode && $debug {
        say "ERROR:  Command '$cmd' returned with exit code '$exitcode'.";
        say "  stderr: $stderr" if $stderr;
        say "  stdout: $stdout" if $stdout;
    }

    if $all {
        return $exitcode, $stderr, $stdout;
    }
    elsif $out {
        return $stdout;
    }
    else {
        return $exitcode;
    }
} # run-command
