use Cro::HTTP::Auth;
use Cro::HTTP::Test;

class MySession does Cro::HTTP::Auth {
    has $.logged-in = False;
    has $.admin = False;
}

sub routes() is export {
    use Cro::HTTP::Router;
    my subset LoggedIn of MySession where .logged-in;
    my subset Admin of MySession where .admin;
    route {
        get -> 'public' {
            content 'text/plain', 'everyone sees this';
        }
        get -> LoggedIn, 'secret' {
            content 'text/plain', 'only logged in';
        }
        get -> Admin, 'admin' {
            content 'text/plain', 'only admin';
        }
    }
}

plan 9;

test-service routes(), fake-auth => MySession.new, {
    test get('/public'),
        status => 200;
    test get('/secret'),
        status => 401;
    test get('/admin'),
        status => 401;

    test-given fake-auth => MySession.new(:logged-in), {
        test get('/public'),
            status => 200;
        test get('/secret'),
            status => 200;
        test get('/admin'),
            status => 401;
    }

    test-given fake-auth => MySession.new(:logged-in, :admin), {
        test get('/public'),
            status => 200;
        test get('/secret'),
            status => 200;
        test get('/admin'),
            status => 200;
    }
}
