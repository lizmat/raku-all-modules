unit module App::Platform::CLI::Attach;

our $data-path;
our $network;
our $domain;

use CommandLine::Usage;

#| Attach to a running container through shell
multi cli('attach',
    $container,         #= NAME
    ) is export {
    try {
        CATCH {
            default {
                cli('attach', :help(True));
            }
        }

        my $name = $container;
        my $proc = run <docker ps --format>, <{{.Names}}>, <--filter>, "name={$container}", :out, :err;
        my $out = $proc.out.slurp-rest;
        $name = $out.lines[0].trim;

        # Figure out which shell is supported
        my $shell = 'bash';
        $proc = run <docker exec -it>, $name, $shell, <-c>, "echo shelltest", :out, :err;
        $shell = 'ash' unless $proc.out.slurp-rest ~~ / ^ shelltest /; 

        my $prompt = '\[\e[38;5;0m\]\[\e[48;5;148m\] platform \[\e[38;5;148m\]\[\e[48;5;238m\]\[\e[0m\]\[\e[38;5;250m\]\[\e[48;5;238m\] ' ~ $name ~' \[\e[38;5;238m\]\[\e[48;5;237m\]\[\e[0m\]\[\e[38;5;250m\]\[\e[48;5;237m\] \w \[\e[38;5;237m\]\[\e[48;5;236m\]\[\e[0m\]\[\e[38;5;15m\]\[\e[48;5;236m\] \$ \[\e[0m\]\[\e[38;5;236m\]\[\e[0m\]';
        run <docker exec -it>, $name, <sh -c>, "export PS1='{$prompt}'; {$shell}";
    }
}

multi cli('attach',
    Bool :h( :help($help) ) #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<attach>
        ).parse.say;
}
