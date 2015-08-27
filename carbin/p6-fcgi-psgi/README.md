# FastCGI::NativeCall::PSGI #

This is a PSGI interface for FastCGI::NativeCall

## Example ##

Basic usage:

    use FastCGI::NativeCall;
    use FastCGI::NativeCall::PSGI;

    my $sock = FastCGI::NativeCall::OpenSocket("/var/www/run/example.sock", 5);
    my $psgi = FastCGI::NativeCall::PSGI.new(FastCGI::NativeCall.new($sock));

    sub dispatch-psgi($env) {
        return [ 200, { Content-Type => 'text/html' }, "Hello world" ];
    }

    $psgi.app(&dispatch-psgi);
    $psgi.run;

Example using a PSGI framework:

    use FastCGI::NativeCall;
    use FastCGI::NativeCall::PSGI;
    use Bailador;

    get "/" => sub {
        "Hello world";
    }

    my $sock = FastCGI::NativeCall::OpenSocket("/var/www/run/example.sock", 5);

    given FastCGI::NativeCall::PSGI.new(FastCGI::NativeCall.new($sock)) {
        .app(&Bailador::dispatch-psgi);
        .run;
    }
