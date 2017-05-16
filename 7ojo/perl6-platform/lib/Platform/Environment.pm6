use v6;
use Platform::Project;
use YAMLish;

class Platform::Environment {

    has Str $.domain = 'localhost';
    has Str $.data-path is rw;
    has Str $.environment;
    has Platform::Project @.projects;
    has Platform::Container @.containers;

    submethod TWEAK {
        my $config = load-yaml $!environment.IO.slurp;
        for $config.Hash.kv -> $project, $data {
            my $project-path = $project ~~ / ^ \/ / ?? $project !! "{self.environment.IO.dirname}/{$project}".IO.absolute;
            if $data ~~ Bool and $data {
                @!projects.push: Platform::Project.new(:domain($!domain), :data-path($!data-path), :project($project-path));
            } elsif $data ~~ Hash {
                @!projects.push: Platform::Project.new(
                    :domain($!domain),
                    :data-path($!data-path),
                    :project($project-path),
                    :override($data.Hash)
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
