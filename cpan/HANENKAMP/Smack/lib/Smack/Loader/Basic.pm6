use v6;

use Smack::Loader;

unit class Smack::Loader::Basic
does Smack::Loader;

multi method load-server(Str $server, %options) returns Smack::Handler {
    my $class = "Smack::Handler::$server";
    require ::($class);
    ::($class).new(|%options);
}

multi method load-server(%options) returns Smack::Handler {
    my $guess = self.guess;
    return unless $guess;
    # callwith... ???
    self.load-server($guess, %options);
}
