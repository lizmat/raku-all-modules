unit module Example::Docker::Build;

use CommandLine::Usage;

#| Build an image from a Dockerfile
multi command('build',
    List :$add-host,                #= Add a custom host-to-IP mapping (host:ip)
    Int  :$cpu-shares,              #= CPU shares (relative weight)
    Str  :$isolation                #= Container isolation technology
    ) is export {
    say "i am here on Example::Docker::Build::command('build')";
}

multi command('build',
    Bool :h( :help($help) )         #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :func(&command),
        :constraint-list<build>
        )
        .parse
        .say;
}
