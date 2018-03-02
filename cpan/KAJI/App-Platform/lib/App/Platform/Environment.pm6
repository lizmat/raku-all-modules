use v6;
use YAMLish;
use App::Platform::Project;
use App::Platform::Git;
use App::Platform::Output;
use Terminal::ANSIColor;

class App::Platform::Environment {

    has Str $.network = 'acme';
    has Str $.domain = 'localhost';
    has Str $.data-path is rw;
    has Str $.environment;
    has Str @.reserved-keys = [ 'type', 'name', 'desc' ];
    has Bool $.skip-dotfiles = False;

    has App::Platform::Project @.projects;
    has App::Platform::Container @.containers;

    submethod TWEAK {
        my $config = load-yaml $!environment.IO.slurp;

        # Git support. Try to fetch repository if it does not exists 
        put '🐱' ~ App::Platform::Output.after-prefix ~ color('yellow'), ~ 'Repositories' ~ color('reset');
        for $config.Hash.sort(*.key)>>.kv.flat -> $project, $data {
            next if @!reserved-keys.contains($project);

            App::Platform::Git.new(
                data    => $data<git>, 
                target  => $!environment.IO.parent ~ '/' ~ $project
                ).clone if $data<git>;
        }
        
        for $config.Hash.sort(*.key)>>.kv.flat -> $project, $data {
            next if @!reserved-keys.contains($project);

            my $project-path = $project ~~ / ^ \/ / ?? $project !! "{self.environment.IO.dirname}/{$project}".IO.absolute;
            if $data ~~ Bool and $data {
                @!projects.push: App::Platform::Project.new(
                    :domain($!domain),
                    :data-path($!data-path),
                    :project($project-path),
                    :skip-dotfiles($!skip-dotfiles)
                    );
            } elsif $data ~~ Hash {
                @!projects.push: App::Platform::Project.new(
                    :domain($!domain),
                    :data-path($!data-path),
                    :project($project-path),
                    :override($data.Hash),
                    :skip-dotfiles($!skip-dotfiles)
                    );
            }
        }
    }

    method run { @.projects.map: { @.containers.push(.run) }; self }

    method start { @.projects.map: { @.containers.push(.start) }; self }

    method stop { @.projects.map: { @.containers.push(.stop) }; self }

    method rm { @.projects.map: { @.containers.push(.rm) }; self }

    method as-string { @.containers.map({.as-string}).join("\n") }

}
