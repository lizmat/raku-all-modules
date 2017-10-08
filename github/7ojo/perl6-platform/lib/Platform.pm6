use v6;
use Platform::Container;
use Platform::Docker::DNS;
use Platform::Docker::Proxy;

class Platform is Platform::Container {

    has Str @.services = 'DNS', 'Proxy';
    
    submethod BUILD {
        self.data-path .= subst(/\~/, $*HOME);
        mkdir self.data-path if not self.data-path.IO.e;
    }

    method create { @.services.map: { ::("Platform::Docker::$_").new(:$.network, :$.domain, :$.data-path).start } }

    method destroy { @.services.map: { ::("Platform::Docker::$_").new(:$.network, :$.domain, :$.data-path).stop } }

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

}
