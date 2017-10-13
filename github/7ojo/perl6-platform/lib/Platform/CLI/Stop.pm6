unit module Platform::CLI::Stop;

our $data-path;
our $network;
our $domain;

use Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;
use Platform;
use Platform::Project;
use Platform::Environment;

#| Stop suspended project or environment
multi cli('stop',
    $path,              #= PATH
    ) is export {
    try {
        CATCH {
            default {
                #.Str.say;
                # say .^name, do given .backtrace[0] { .file, .line, .subname }
                put color('red') ~ "ERROR: $_" ~ color('reset');
                exit;
            }
        }
        if Platform.is-environment($path) {
            my $obj = Platform::Environment.new(:environment($path), :$network, :$domain, :$data-path).stop;
            put '🚩' ~ Platform::Output.after-prefix ~ color('yellow') ~ 'Summary' ~ color('reset');
            put $obj.as-string;
        } else {
            Platform::Project.new(:project($path), :$network, :$domain, :$data-path).stop;
        }
    }
}

multi cli('stop',
    :h( :help($help) )  #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<stop>
        ).parse.say;
}

