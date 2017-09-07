# Proc::More
[![Build Status](https://travis-ci.org/tbrowder/Proc-More-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Proc-More-Perl6)

### Note: This module replaces module `Linux::Proc::Time` which is deprecated.

This module provides functions using Perl 6's **Proc** class.  Two of the most noteworthy ones are:

+ `run-command`
+ `time-command`

This module uses the GNU **time** command (usually installed as '/usr/bin/time') to time user commands.

### WARNING:  These functions have been tested only on Linux systems (but the author plans to port them to other OSs).

## Synopsis

    use Proc::More :run-command;
    my $cmd = "some-user-prog arg1 arg2";
	my $other-dir = $*TMPDIR";
    my ($exitcode, $stderr, $stdout) = run-command $cmd, :dir($other-dir), :all;

    use Proc::More :time-command;
    my $cmd = "some-user-prog arg1 arg2";
    my $user-time = time-command $cmd;
    say $user-time; # output: 42.70 # seconds


## Getting the **time** command

On Debian hosts the **time** command may not installed by default but it is available in
package 'time'.  It can also be built from source available at the Free Software
Foundation's git site.  Clone the source repository:

    $ git clone https://git.savannah.gnu.org/git/time.git

The build and install instructions are in the repository along with the source code.

Unfortunately, there is no equivalent command available for Windows unless you install Cygwin or an equivalent system.

## The **time** command

The details for running **time** are described in **time**'s man page which can be viewed by
running 'man 1 time' at the command line.

This module will look for time in the following locations and order:

- the location defined by the LINUX_PROC_TIME environment variable
- /usr/local/bin/time
- /usr/bin/time

If the **time** command is not found, an exception will be thrown.
Likewise, if the **time** command returns an exit code other than zero, an exception will be thrown.

# The Proc::More module

The routines are described in detail in
[ALL-SUBS](https://github.com/tbrowder/Linux-Proc-Time-Perl6/blob/master/docs/ALL-SUBS.md)
which shows a short description of each exported routine along along
with its complete signature.

## The :$typ and :$fmt named parameters

The two named parameters control the type and format of the output
from the time-command.  (Note there is a fourth format which is used
if the **:$fmt** variable is not used or defined.  In that case only
the raw time in seconds is shown without any other formatting.)  The
allowed values and a short description are described in the source
code and are repeated here:

```Perl6
my token typ { ^ :i             # the desired time(s) to return:
                    a|all|      # show all three times:
                                #   "Real: [time in desired format]; User: [ditto]; Sys: [ditto]"
                    r|real|     # show only the real (wall clock) time
                    u|user|     # show only the user time (default)
                    s|sys       # show only the system time
             $ }
my token fmt { ^ :i             # the desired format for the returned time(s)
                    s|seconds|  # time in seconds with an appended 's': "30.42s"
                    h|hms|      # time in hms format: "0h00m30.42s"
                    ':'|'h:m:s' # time in h:m:s format: "0:00:30.42"
             $ }
```

## Status

This version is 0.\*.\* which is considered usable but may not be ready
for production.  The APIs are subject to change in which case the
version major number will be updated. Note that newly added
subroutines or application programs are not considered a change in
API.


## Debugging

For debugging, use one of the following methods:

- set the module's $DEBUG variable:

```Perl6
$Proc::More::DEBUG = True;
```

- set the environment variable:

```Perl6
PROC_MORE_DEBUG=1
```

## Contributing

Interested users are encouraged to contribute improvements and
corrections to this module, and pull requests, bug reports, and
suggestions are always welcome.


## LICENSE and COPYRIGHT

Artistic 2.0. See [LICENSE](https://github.com/tbrowder/Proc-More-Perl6/blob/master/LICENSE).

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>>
