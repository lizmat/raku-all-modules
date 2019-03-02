use v6;

unit class Smack::Runner;

use Smack::Handler;
use Smack::Loader;

sub MAIN(
    Str  :a(:$app),
    Str  :o(:$host),
    Int  :p(:$port),
) is export(:MAIN) {
    my $runner = Smack::Runner.new(
        |do with $app  { :$app },
        |do with $host { :$host },
        |do with $port { :$port },
    );
    $runner.run;
}

has $.app = 'app.p6w';
has Str $.host = '0.0.0.0';
has Int $.port = 5000;
has Str $!loader-name = 'Basic';
has Smack::Loader $!loader = self!build-loader;
has Str $!server-name;

has %.server-options =
    host => $!host,
    port => $!port,
    ;

method !build-loader() returns Smack::Loader {
    my $class = "Smack::Loader::$!loader-name";
    require ::($class);
    ::($class).new;
}

method load-server($loader) returns Smack::Handler {
    if $!server-name.defined {
        $loader.load-server($!server-name, %!server-options);
    }
    else {
        $loader.load-server(%!server-options);
    }
}

method run {
    my $server = self.load-server($!loader);

    my &app = do given $.app {
        when Str { $!app.IO.slurp.EVAL }
        when Callable { $.app }
        default { die "unknown app argument type" }
    }

    $server.run(&app);
}
