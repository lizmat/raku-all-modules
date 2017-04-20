use v6;
use Platform::Container;
use YAMLish;
use Terminal::ANSIColor;

class Platform::Project {

    has Str $.config;
    has Str $.project;
    has Str $.project-dir;
    has Str $.project-file;
    has Str $.network = 'acme';
    has Str $.domain = 'localhost';
    has Str $.data-path is rw;
    has %.override;

    has %.defaults =
        command => '/bin/bash',
        volumes => []
        ;

    method TWEAK {
        if self.project.IO.extension eq 'yml' {
            $!project-dir = self.project.IO.dirname.IO.absolute;
            $!project-file = self.project.IO.absolute;
        } else {
            $!project-dir = self.project.IO.absolute;
            $!project-file = "$_/project.yml".IO.absolute if not $!project-file and "$_/project.yml".IO.e for self.project ~ "/docker", self.project;
        }
    }

    method run {
        my $config = $.project-file.IO.e ?? load-yaml $.project-file.IO.slurp !! item(%.defaults);
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
        my $class = "Platform::Docker::Container"; # TODO: Get more container variants here some day
        %values<name> = self.project-dir.IO.basename;
        %values<projectdir> = self.project-dir;
        %values<data-path> = self.data-path;
        %values<network> = self.network;
        %values<domain> = self.domain;
        require ::($class);
        ::($class).new(|%values);
    }

}
