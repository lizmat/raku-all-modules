unit module App::Platform::CLI::Rm;

our $data-path;
our $network;
our $domain;

use App::Platform::Output;
use Terminal::ANSIColor;
use CommandLine::Usage;
use App::Platform;
use App::Platform::Project;
use App::Platform::Environment;

#| Remove stopped project or environment
multi cli('rm',
    $path,              #= PATH
    ) is export {
    try {
        CATCH {
            default {
                # say .^name, do given .backtrace[0] { .file, .line, .subname }
                put color('red') ~ "ERROR: $_" ~ color('reset');
                exit;
            }
        }
        if App::Platform.is-environment($path) {
            my $obj = App::Platform::Environment.new(:environment($path), :$network, :$domain, :$data-path);
            put '🚩' ~ App::Platform::Output.after-prefix ~ color('yellow') ~ 'Summary' ~ color('reset');
            put $obj.rm.as-string;
        } else {
            my $obj = App::Platform::Project.new(:project($path), :$network, :$domain, :$data-path);
            my $res = $obj.rm;
            put $res.as-string if $res.last-result<err> and $res.last-result<err>.chars > 0;
        }
    }
}

multi cli('rm',
    :h( :help($help) )  #= Print usage
    ) is export {
    CommandLine::Usage.new(
        :name( %*ENV<PERL6_PROGRAM_NAME> ),
        :func( &cli ),
        :desc( &cli.candidates[0].WHY.Str ),
        :filter<rm>
        ).parse.say;
}

