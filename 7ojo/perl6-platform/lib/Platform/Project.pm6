use v6;
use Platform::Container;
use YAMLish;
use Terminal::ANSIColor;

class Platform::Project {

    has Str $.config;
    has Str $.project;
    has Str $.network = 'acme';
    has Str $.domain = 'localhost';
    has Str $.data-path is rw;
    has %.override;

    has %.defaults =
        command => '/bin/bash',
        volumes => []
        ;

    method run {
        my ($config, $projectyml-path);
        $projectyml-path = "$_/project.yml" if not $projectyml-path and "$_/project.yml".IO.e for self.project ~ "/docker", self.project;
        $config = $projectyml-path ?? load-yaml $projectyml-path.IO.slurp !! item(%.defaults);
        for %.override.kv -> $key, $val {
            if $config{$key} ~~ Array {
                $config{$key} = flat($config{$key}.Array, $val.Array).Array;
            } elsif $config{$key} ~~ Hash {
                for $val.Hash.kv -> $inskey, $insval {
                    $config{$key}{$inskey} = $insval;
                }
            } else {
                $config{$key} = $val
            }
        }
        my $cont = self.load-cont(
            config-data => $config
            );
        for <Build Users Dirs Files> {
            put color('yellow'), "» {$_}", color('reset');
            $cont."{$_.lc}"();
        }
        my $res = $cont.last-command: $cont.run;

        put color('yellow'), "» Exec", color('reset'), ' (waiting for services)';
        for <. . . . .> {
            print $_;
            sleep 1;
        }
        say '';
        $cont.exec;

        $res;
    }

    method start { self.load-cont.start.last-command }

    method stop { self.load-cont.stop.last-command }

    method rm { self.load-cont.rm.last-command }

    method load-cont(*%values) {
        # TODO: Get more container variants here some day
        my $class = "Platform::Docker::Container";
        %values<name> = self.project.IO.basename;
        %values<projectdir> = self.project;
        %values<data-path> = self.data-path;
        %values<network> = self.network;
        %values<domain> = self.domain;
        require ::($class);
        ::($class).new(|%values);
    }

}
