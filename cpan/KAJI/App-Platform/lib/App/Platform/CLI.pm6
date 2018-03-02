unit module App::Platform::CLI;

use App::Platform::CLI::Attach;
use App::Platform::CLI::Create;
use App::Platform::CLI::Destroy;
use App::Platform::CLI::Run;
use App::Platform::CLI::Remove;
use App::Platform::CLI::Rm;
use App::Platform::CLI::Start;
use App::Platform::CLI::Stop;
use App::Platform::CLI::SSL;
use App::Platform::CLI::SSH;
use App::Platform::CLI::Info;
use YAMLish;

our $data-path is export(:vars);

multi cli is export {
    OUTER::USAGE();
}

multi set-defaults(
    :D( :debug($debug) ),                                   #= Enable debug mode
    :a( :data-path($data-path) )    = '$HOME/.platform',    #= Location of resource files
    :d( :domain( $_domain ) )       = 'localhost',          #= Domain address 
    :n( :network( $network ) )      = 'acme',               #= Network name
    ) is export {

    # load some defaults from config.yml
    my $domain = $_domain;
    my $config-file = $data-path ~ '/config.yml';
    $config-file = $config-file.subst(/ '$HOME' /, $*HOME);
    if $config-file.IO.e {
        my $config = load-yaml $config-file.IO.slurp;
        $domain = $config<domain> if $config<domain>;
    }
    
    set-defaults(
        data-path   => $data-path,
        debug       => $debug,
        domain      => $domain,
        network     => $network,
        fallback    => 1, # force select set-defaults function below
        );
}

multi set-defaults(*@args, *%args) {
    
    %args<data-path> ||= '$HOME/.platform';
    %args<domain>    ||= 'localhost';
    %args<network>   ||= 'acme';

    for <data-path domain network> -> $class-var {
        for <
            Attach
            Create
            Destroy
            Run
            Remove
            Rm
            Start
            Stop
            SSL
            SSH
            Info
            > -> $module {
            my $class-name = "App::Platform::CLI::$module";
            if %args{$class-var}:exists {
                my $value = %args{$class-var};
                $value = $value.subst(/ '$HOME' /, $*HOME);
                ::($class-name)::("\$$class-var") = $value;
            }
        }
        %args«$class-var»:delete;
    }
    %args<fallback>:delete;
    %args<debug>:delete;
    %args;
}
