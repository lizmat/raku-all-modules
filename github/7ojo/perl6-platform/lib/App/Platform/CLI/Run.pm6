unit module App::Platform::CLI::Run;

our $data-path;
our $network;
our $domain;

use App::Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;
use App::Platform;
use App::Platform::Project;
use App::Platform::Environment;

#| Initialize single project or environment with collection of projects
multi cli('run',
    $path,              #= PATH
    ) is export {
    try {
        CATCH {
            default {
                # say .^name, do given .backtrace[0] { .file, .line, .subname }
                # say $_;
                put color('red') ~ $_ ~ color('reset');
                cli('run', :help(True));
            }
        }
        #put '🚩' ~ App::Platform::Output.after-prefix ~ color('yellow') ~ 'Summary' ~ color('reset');
        if App::Platform.is-environment($path) {
            put App::Platform::Environment.new(:environment($path), :$domain, :$network, :$data-path).run.as-string;
        } else {
            put App::Platform::Project.new(:project($path), :$network, :$domain, :$data-path).run.as-string;
        }
    }
}

multi cli('run',
    :h( :help($help) )  #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<run>
        ).parse.say;
}

