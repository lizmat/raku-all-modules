unit module App::Platform::CLI::Info;

our $data-path;
our $network;
our $domain;

use App::Platform::Output;
use Terminal::ANSIColor;

#| Display system-wide information
multi cli('info') is export {
    
    # status? is dns and proxy available running or not?
    my $status = 'unavailable';
    my $proc = run <docker ps --format>, <{{.Names}}>, <--filter>, "name=platform", :out, :err;
    if not $proc.exitcode.Bool {
        $status = $proc.out.slurp-rest.lines.elems >= 2 
            ?? color('green') ~ 'running' ~ color('reset') 
            !! color('red') ~ 'not running' ~ color('reset')
            ;
    }

    # has ssl certificates generated?
    my $ssl-certs = 'unavailable';
    my $ssl-path = "$data-path/$domain/ssl";
    $ssl-path = $ssl-path.subst(/ '$HOME' /, $*HOME);
    if $ssl-path.IO.d and "$ssl-path/server-key.crt".IO.e and "$ssl-path/server-key.key".IO.e {
        $ssl-certs = color('green') ~ 'available' ~ color('reset');
    }

    # has ssh keys generated?
    my $ssh-keys = 'unavailable';
    my $ssh-path = "$data-path/$domain/ssh";
    $ssh-path = $ssh-path.subst(/ '$HOME' /, $*HOME);
    if $ssh-path.IO.d and "$ssh-path/id_rsa".IO.e and "$ssh-path/id_rsa.pub".IO.e {
        $ssh-keys = color('green') ~ 'available' ~ color('reset');
    }

    put '🏗️' ~ App::Platform::Output.after-prefix ~ color('170,85,0'), ~ 'Platform' ~ color('reset');
    for <status ssl-certs ssh-keys domain network data-path> {
        put ' ' ~ App::Platform::Output.after-prefix ~ " $_:\t" ~ $::($_);
    }

}

