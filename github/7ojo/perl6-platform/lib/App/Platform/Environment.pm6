use v6;
use YAMLish;
use App::Platform::Project;
use App::Platform::Git;

class App::Platform::Environment {

    has Str $.network = 'acme';
    has Str $.domain = 'localhost';
    has Str $.data-path is rw;
    has Str $.environment;
    has Str @.reserved-keys = [ 'type', 'name', 'desc' ];

    has App::Platform::Project @.projects;
    has App::Platform::Container @.containers;

    submethod TWEAK {
        my $config = load-yaml $!environment.IO.slurp;
        for $config.Hash.sort(*.key)>>.kv.flat -> $project, $data {
            next if @!reserved-keys.contains($project);

            # Git support. Try to fetch repository if it does not exists
            App::Platform::Git.new(
                data    => $data<git>, 
                target  => $!environment.IO.parent ~ '/' ~ $project
                ).clone if $data<git>;

            my $project-path = $project ~~ / ^ \/ / ?? $project !! "{self.environment.IO.dirname}/{$project}".IO.absolute;
            if $data ~~ Bool and $data {
                @!projects.push: App::Platform::Project.new(:domain($!domain), :data-path($!data-path), :project($project-path));
            } elsif $data ~~ Hash {
                @!projects.push: App::Platform::Project.new(
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
