Name
====
`Async::Command`

Description
===========
`Async::Command` will run the specified command in a promise,
enforce an optional time out, capture $*ERR & $*OUT, and record
the exit status value. All of this is contained in an
`Async::Command::Result` object for examination afterward.

Synopsis
========

Execute a command
-----------------

    use Async::Command;

    # run a simple command
    my $result = Async::Command.new(:command</usr/bin/uname -n>).run;

    # run a command with a persistent time out
    my Async::Command $cmd .= new(:command</usr/bin/uname -s>, :1time-out);
    $result = $cmd.run;
    # run the same command again with a new time out
    $result = $cmd.run(:time-out(.001));

Methods
=======

new()
-----

    :@command
    
Required List or Array of the command and arguments. Absolute paths are encouraged.
    
    :$time-out
    
Optional persistent time-out in Real seconds. '0' indicates no time out.

run()
-----

    :$time-out
    
Optional time-out override in Real seconds. Useful for re-running the
command with a new value or '0' for no time out.

Examples
========
An example script that runs a curl command
------------------------------------------

    use Async::Command;

    my @command = [
                    'curl',
                    '-H', 'Content-Type:application/json',
                    '-d', '{"user":"myuserid","password":"mYpAsSwOrD!"}',
                    '-X', ' POST',
                    '-k',
                    '-s',
                    'https://10.20.30.40/api/get_token',
                 ];

    dd $ = Async::Command.new(:@command, :2time-out).run;

Returns an Async::Command::Result object
----------------------------------------

    Async::Command::Result $ =
        Async::Command::Result.new(
            command => Array[Str].new(
                "curl", "-H", "Content-Type:application/json",
                "-d", "\{\"user\":\"myuserid\",\"password\":\"mYpAsSwOrD!\"}",
                "-X", " POST",
                "-k", "-s",
                "https://10.20.30.40/api/get_token"
            ),
            exit-code => 0,
            stderr-results => "",
            stdout-results => "\{\"token\":\"123456789123456789123456789123456789\"}",
            time-out => 2,
            timed-out => Bool::False,
            unique-id => Str
        )

See Also
========
    Async::Command::Multi
 
    Async::Command::Result
