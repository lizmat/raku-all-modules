unit module Example::Docker::Attach;

use CommandLine::Usage;

#| Attach local standard input, output, and error streams to a running container
multi command('attach',
    $name,                      #= CONTAINER
    :$detach-keys,              #= Override the key sequence for detaching a container
    :$no-stdin,                 #= Do not attach STDIN
    :$sig-proxy                 #= Proxy all received signals to the process (default true)
    ) is export {
    say "i am here on Example::Docker::Attach::command('attach')";
    for <name detach-keys no-stdin sig-proxy> -> $varname {
        say "$varname: " ~ $::($varname) if $::($varname);
    }
}

multi command('attach',
    Bool :h( :help($help) )     #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( $*PROGRAM-NAME.IO.basename ),
        :func( &command ),
        :desc( &command.candidates[0].WHY.Str ),
        :filter<attach>
        ).parse.say;
}
