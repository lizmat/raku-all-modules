unit module Platform::CLI::Attach;

our $data-path;
our $network;
our $domain;

use CommandLine::Usage;

#| Attach to a running container through shell
multi cli('attach',
    $project,               #= PATH
    ) is export {
    try {
        CATCH {
            default {
                cli('attach', :help(True));
            }
        }
        require Platform::Project;
        Platform::Project.new(:$project, :$data-path).attach;
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
