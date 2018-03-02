unit module App::Platform::CLI::Attach;

our $data-path;
our $network;
our $domain;

use CommandLine::Usage;
use App::Platform::Output;
use Terminal::ANSIColor;

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
        $name = $out.lines.grep({ / ^ $container / }).trim;
        if $name.chars == 0 {
           put BOLD, "error: did not find any matching container", RESET;
           exit;
        }

        # Figure out which shell is supported
        my $shell = 'bash';
        $proc = run <docker exec -it>, $name, $shell, <-c>, "echo shelltest", :out, :err;
        $shell = 'ash' unless $proc.out.slurp-rest ~~ / ^ shelltest /;

        # Open shell under container
        run <docker exec -it>, $name, $shell;
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
