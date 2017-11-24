use v6;
use App::Platform::Container;
use App::Platform::Docker::DNS;
use App::Platform::Docker::Proxy;
use YAMLish;

class App::Platform is App::Platform::Container {

    has Str @.services = 'DNS', 'Proxy';

    submethod BUILD {
        self.data-path .= subst(/\~/, $*HOME);
        mkdir self.data-path if not self.data-path.IO.e;
    }

    method create { @.services.map: { ::("App::Platform::Docker::$_").new(:$.network, :$.domain, :$.data-path, :$.dns-port).start } }

    method destroy { @.services.map: { ::("App::Platform::Docker::$_").new(:$.network, :$.domain, :$.data-path).stop } }

    method ssl('genrsa') {
        my $ssl-dir = $.data-path ~ '/' ~ self.domain ~'/ssl';
        mkdir $ssl-dir if not $ssl-dir.IO.e;
        my $proc = run <openssl genrsa -out>, "$ssl-dir/server-key.key", <4096>, :out, :err;
        my $out = $proc.out.slurp-rest;
        my $err = $proc.err.slurp-rest;
        run <openssl rsa -in>, "$ssl-dir/server-key.key", <-pubout -out>, "$ssl-dir/server-key.crt";
    }

    method ssh('keygen') {
        my $ssh-dir = $.data-path ~ '/' ~ self.domain ~ '/ssh';
        mkdir $ssh-dir if not $ssh-dir.IO.e;
        run <ssh-keygen -t rsa -q -N>, '', '-f', "$ssh-dir/id_rsa";
    }

    method is-environment(Str $path) {
        my $is-environment = False;
        if $path.IO.f {
            my $dir = $path.IO.dirname;
            my $config = load-yaml $path.IO.slurp;
            if $config<type> and $config<type> eq 'environment' {
                $is-environment = True;
            } else { # Fallback
                my $first-entry = $config.keys[0];
                if "$dir/$first-entry".IO.d { # if it's directory then yml file is probably environment definition file
                    $is-environment = True;
                }
            }
        }
        $is-environment;
    }

}
