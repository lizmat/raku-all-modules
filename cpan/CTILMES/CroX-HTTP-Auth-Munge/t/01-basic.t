use Test;
use Test::When <extended>;
use Cro::HTTP::Test;
use CroX::HTTP::Auth::Munge;
use CroX::HTTP::Auth::Munge::Header;

plan 10;

class MySession does CroX::HTTP::Auth::Munge::Session
{
    method a { $.json<a> }
}

class MyAuth does CroX::HTTP::Auth::Munge[MySession] {}

sub routes()
{
    use Cro::HTTP::Router;

    route
    {
        before MyAuth.new;

        get -> MySession $session, 'text'
        {
            content 'text/plain', $session.payload
        }

        get -> MySession $session, 'json'
        {
            content 'application/json', $session.json
        }

        get -> MySession $session, 'a'
        {
            content 'text/plain', $session.a
        }

        get -> MySession $session, 'methods'
        {
            content 'application/json',
                    %( uid => $session.uid, gid => $session.gid )
        }
    }
}

test-service routes(),
{
    test get('/text'), status => 401;   # No Authorization, forbidden

    test get('/text', headers => [ munge('this') ]),
         status => 200,
         content-type => 'text/plain',
         body-text => '"this"';

    test get('/json'), status => 401;

    test get('/json', headers => [ munge(%( a => 1, b => 2)) ]),
         status => 200,
         content-type => 'application/json',
         json => %( a => 1, b => 2);

    test get('/a'), status => 401;

    test get('/a', headers => [ munge(%(a => 'stuff')) ]),
         status => 200,
         content-type => 'text/plain',
         body-text => 'stuff';

    test get('/methods'), status => 401;

    test get('/methods', headers => [ munge ]),
         status => 200,
         content-type => 'application/json',
         json => %( uid => +$*USER, gid => +$*GROUP );


    my $munge = munge('this');

    test get('/text', headers => [ $munge ]),  # First use works
         status => 200,
         content-type => 'text/plain',
         body-text => '"this"';

    test get('/text', headers => [ $munge ]),  # replay credential fails
         status => 401;
}

done-testing;
