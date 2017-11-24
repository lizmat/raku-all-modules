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

our $data-path is export(:vars);

multi cli is export {
    OUTER::USAGE();
}

multi set-defaults(
    :D( :debug($debug) ),                                   #= Enable debug mode
    :a( :data-path($data-path) )    = '$HOME/.platform',    #= Location of resource files
    :d( :domain( $domain ) )        = 'localhost',          #= Domain address 
    :n( :network( $network ) )      = 'acme',               #= Network name
    ) is export {
    set-defaults(
        data-path   => $data-path,
        debug       => $debug,
        domain      => $domain,
        fallback    => 1,
        network     => $network,
        );
}

multi set-defaults(*@args, *%args) {
    
    # TODO: Refactor some how. Duplicates default values.
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
