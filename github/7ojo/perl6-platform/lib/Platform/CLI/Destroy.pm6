unit module Platform::CLI::Destroy;

our $data-path;
our $network;
our $domain;

use Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;

#| Shutdown shared platform services
multi cli('destroy') is export {
    try {
        CATCH {
            default {
                say $_;
                cli('destroy', :help(True));
            }
        }
        use Platform; # TODO: can't get require to work
        Platform.new(:$network, :$domain, :$data-path).destroy;
    }
}

multi cli('destroy',
    :h( :help($help) )  #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<destroy>
        ).parse.say;
}

