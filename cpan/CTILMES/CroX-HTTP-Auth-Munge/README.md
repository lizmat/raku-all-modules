CroX::HTTP::Auth::Munge
=======================

`CroX::HTTP::Auth::Munge` is a
[`Cro::HTTP::Auth`](https://cro.services/docs/http-auth-and-sessions)
class for using [`Munge`](https://github.com/CurtTilmes/perl6-munge)
authentication with [Cro](https://cro.services).

## Concept

On the client side, a payload that can be any basic data structure (or
just a plain string, or even nothing at all) is optionally encoded
with JSON, then passed to the 'MUNGE' service to encode into a
credential token.

That token is passed from client to server in the `Authorization`
header, with authorization method `MUNGE` (non-standard) followed by
the token.  Something like this:

```
Authorization: MUNGE MUNGE:AwQDAACo2CBRY7RWv/KTPN7WgyDcSXbnzrIBOITOEIeroK3nS8ND0GkZuqtaZnuBrZdSxzjZ/C+NwDkqTFHrgmiIbtwrbvKNCNeXYbR2BM6bxDz/PRGyN/I=:
```

The server decodes the token and makes the credentials available to
the HTTP server code.

See the main [MUNGE](https://github.com/dun/munge/wiki) web page for
more information.

## Server

This module gives you two classes (really roles so you can customize):

### `CroX::HTTP::Auth::Munge::Session`

Methods:

`.munge` - returns the `Munge` object used for the decode, you can
query it for things like the `.cipher`, `.zip`, etc. used to encode
the token.

`.uid` - The UID of the user.

`.gid` - The GID of the user.

`.encode-time` - The `DateTime` the token was encoded.

`.addr4` - The dotted quad for the IPv4 address of the host that
encoded the token.

`.payload` - The payload from the token.

`.json` - JSON decoded version of the payload.

### `CroX::HTTP::Auth::Munge`

`Cro::HTTP::Middleware` that can be used to handle the Munge'd
Authorization.

This is parameterized with a session that `does` the
`CroX::HTTP::Auth::Munge::Session` role.

For each `Cro::HTTP::Request` it handles, it will decode the
`Authorization` MUNGE credentials, and create a new session that
stores the decoded credentials that can be queried from within any
route.



### Basic Server:

From a `Cro` `route {}` block, use an instance in a before statement:

```
route {
    before CroX::HTTP::Auth::Munge[CroX::HTTP::Auth::Munge::Session].new;

    get -> CroX::HTTP::Auth::Munge::Session $session {
        # Use $session.uid, $session.gid, $session.json, etc.
        # to do something
        content 'text/plain', "Ok\n";
}
```

See [eg/server.p6](https://github.com/CurtTilmes/perl6-crox-http-auth-munge/blob/master/eg/server.p6) for a working example.

A default `Munge` object will be used, but you can override with a
custom one if you like:

```
my $munge = Munge.new(cipher => ..., ttl => ...);
before CroX::HTTP::Auth::Munge[CroX::HTTP::Auth::Munge::Session].new(:$munge);
```

### Customize Session Server:

It can be useful to customize a little further to make the session a
little easier to use.

Assume the client will be passing in a data structure like this:
```
{  a => ..., b => ... }
```

You can put in methods to pull those bits out of the JSON:

```
class MySession does CroX::HTTP::Auth::Munge::Session
{
    method a { $.json<a> }
    method b { $.json<b> }
}

class MyAuth does CroX::HTTP::Auth::Munge[MySession] {}

my $routes = route
{
    before MyAuth.new;

    get -> MySession $session {
        # Use $esssion.uid, $session.a, $session.b
        content 'text/plain', "Ok\n";
    }
};
```

See [eg/customsession.p6](https://github.com/CurtTilmes/perl6-crox-http-auth-munge/blob/master/eg/customsession.p6) for a working example.

### Client

You can use `curl` as a basic client, adding the `MUNGE` token to the
`Authorization` header on the command line like this (`bash` shell
syntax):

```
curl -v -H "Authorization: MUNGE $(echo -n '{"a":1,"b":2}' | munge)" http://localhost:10000/
```

You can also use the `Munge` module to build the header from within
Perl 6 as a `Cro::HTTP::Header` object:

```
my $cred = Munge.new.encode(to-json($payload));
Cro::HTTP::Header.new(name => 'Authorization', value => "MUNGE $cred");
```

As a convenience, this module includes a
`CroX::HTTP::Auth::Munge::Header` that exports a simple `munge()`
subroutine that does just that.

You can easily use it with `Cro::HTTP::Client`:

```
use Cro::HTTP::Client;
use CroX::HTTP::Auth::Munge::Header;

my %secure = a => 1, b => 2;

my $response = await Cro::HTTP::Client.get: "http://localhost:10000/",
    headers => [ munge(%secure) ];

put await $response.body-text;
```

See [eg/client.p6](https://github.com/CurtTilmes/perl6-crox-http-auth-munge/blob/master/eg/client.p6) for a working example.

Note you can never re-use the MUNGE token or header -- it will fail to
decode if replayed.  A new token must be produced for each use.

## License

Copyright © 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
No copyright is claimed in the United States under Title 17,
U.S.Code. All Other Rights Reserved.
