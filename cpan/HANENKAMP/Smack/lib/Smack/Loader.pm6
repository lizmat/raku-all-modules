use v6;

unit role Smack::Loader;

use Smack::Handler;

has &.app is rw;

method watch(*@paths) {
    # do nothing. override in subclass
}

method auto(Smack::Loader:U: *@args) {
    my $backend = self.guess
        or die "Could not auto-guess server implementation. Set it with SMACK_SERVER";

    my $server = self.load($backend, @args);

    CATCH {
        default {
            if %*ENV<SMACK_ENV>//'' eq 'development' {
                warn "Autoloading '$backend' failed. Falling back to the Standalone. "
                   ~ "(You might need to install Plack::Handler::$backend from the Ecosystem."
                   ~ "Caught error was: $_)\n";
            }

            $server = self.load('Standalone', @args);
        }
    }

    $server;
}

method load($server, @args) {
    my $server-class = ::("Smack::Handler::$server");
    require $server-class;

    $server-class.new(|@args);
}

method preload-app(&builder) {
    &!app = builder();
}

method guess() {
    return %.env<PLACK_SERVER> if %.env<PLACK_SERVER>;
    return 'CGI' if %.env<GATEWAY_INTERFACE>;

    return "Standalone";
}

method env() { %*ENV }

method run(Smack::Handler $server) {
    $server.run(&.app);
}
