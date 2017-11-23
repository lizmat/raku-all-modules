unit module Example::Docker;

use Example::Docker::Attach;
use Example::Docker::Build;

multi command is export {
    OUTER::USAGE();
}

multi set-defaults(
    Int :$dns-port = 53,                    #= DNS server port
    Str :$config = '$HOME/.docker',         #= Location of client config files
    :D( :debug($debug) ),                   #= Enable debug mode
    :$help,                                 #= Print usage
    List :H( :host($host) ),                #= Daemon socket(s) to connect to
    :l( :log-level($log-level) ) = 'info',  #= Set the logging level ("debug"|"info"|"warn"|"error"|"fatal")
    :$tls,                                  #= Use TLS; implied by --tlsverify
    :$tlscacert = '$HOME/.docker/ca.pem',   #= Trust certs signed only by this CA
    :$tlscert = '$HOME/.docker/cert.pem',   #= Path to TLS certificate file
    :$tlskey = '$HOME/.docker/key.pem',     #= Path to TLS key file
    :$tlsverify,                            #= Use TLS and verify the remote
    :v( :version($version) )                #= Print version information and quit
    ) is export {

}

multi set-defaults(*@args, *%args) {

}
