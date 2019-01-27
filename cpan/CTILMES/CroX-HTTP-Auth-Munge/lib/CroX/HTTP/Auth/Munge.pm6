use Cro::HTTP::Middleware;
use Cro::HTTP::Auth;
use JSON::Fast;
use Munge;

role CroX::HTTP::Auth::Munge::Session does Cro::HTTP::Auth
{
    has Munge $.munge handles<encode-time addr4 uid gid>;
    has $.payload;
    has $.json;

    method json { $!json // ($!json = from-json($!payload)) }
}

role CroX::HTTP::Auth::Munge[CroX::HTTP::Auth::Munge::Session ::TSession]
    does Cro::HTTP::Auth
    does Cro::HTTP::Middleware::Request
{
    has Munge $.munge = Munge.new;

    method process(Supply $requests --> Supply)
    {
        supply whenever $requests -> $req
        {
            my $auth = Nil;
            with $req.header('Authorization') {
                my $part = .split(' ');
                if $part[0] eq 'MUNGE'
                {
                    my $munge = $!munge.clone;
                    try my $payload = $munge.decode($part[1]);
                    with $payload
                    {
                        $auth = TSession.new(:$munge, :$payload);
                    }
                }
            }
            $req.auth = $auth;
            emit $req;
        }
    }
}
