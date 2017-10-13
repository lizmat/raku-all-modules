unit module Platform::CLI::Start;

our $data-path;
our $network;
our $domain;

use Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;
use Platform;
use Platform::Project;
use Platform::Environment;

#| Start suspended project or environment
multi cli('start',
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
            my $obj = Platform::Environment.new(:environment($path), :$network, :$domain, :$data-path).start;
            put '🚩' ~ Platform::Output.after-prefix ~ color('yellow') ~ 'Summary' ~ color('reset');
            put $obj.as-string;
        } else {
            put Platform::Project.new(:project($path), :$network, :$domain, :$data-path).start.as-string;
        }
    }
}

multi cli('start',
    :h( :help($help) )  #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<start>
        ).parse.say;
}

