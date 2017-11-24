unit module App::Platform::CLI::Stop;

our $data-path;
our $network;
our $domain;

use App::Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;
use App::Platform;
use App::Platform::Project;
use App::Platform::Environment;

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
        if App::Platform.is-environment($path) {
            my $obj = App::Platform::Environment.new(:environment($path), :$network, :$domain, :$data-path).stop;
            put '🚩' ~ App::Platform::Output.after-prefix ~ color('yellow') ~ 'Summary' ~ color('reset');
            put $obj.as-string;
        } else {
            App::Platform::Project.new(:project($path), :$network, :$domain, :$data-path).stop;
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

