# Subroutines Exported by the `:ALL` Tag

### Contents

| Col 1 | Col 2 | Col 3 |
| --- | --- | --- |
| [run-command](#run-command) | [seconds-to-hms](#seconds-to-hms) | [time-command](#time-command) |
### sub run-command
- Purpose: Return input time in seconds (without or with a trailing 's') or convert time in seconds to hms or h:m:s format.
- Params : Time in seconds.
- Returns: Time in in seconds (without or with a trailing 's') or hms format, e.g, '3h02m02.65s', or h:m:s format, e.g., '3:02:02.65'.
```perl6
sub run-command($Time,
                   :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                   --> Str) is export(:run-command) {#...}
```
### sub seconds-to-hms
- Purpose: Return input time in seconds (without or with a trailing 's') or convert time in seconds to hms or h:m:s format.
- Params : Time in seconds.
- Returns: Time in in seconds (without or with a trailing 's') or hms format, e.g, '3h02m02.65s', or h:m:s format, e.g., '3:02:02.65'.
```perl6
sub seconds-to-hms($Time,
                   :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                   --> Str) is export(:seconds-to-hms) {#...}
```
### sub time-command
- Purpose: Collect the process times for a system or user command (using the GNU 'time' command).
- Params : The command as a string, and three named parameters that describe which type of time values to return and in what format. Note that special characters are not recognized by the 'run' routine, so results may not be as expected if they are part of the command.
- Returns: A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.
```perl6
sub time-command(Str:D $cmd,
                 :$typ where { $typ ~~ &typ } = 'u',            # see token 'typ' definition
                 :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                 Bool :$list = False,                           # return a list as in the original API
                ) is export(:time-command) {#...}
```
