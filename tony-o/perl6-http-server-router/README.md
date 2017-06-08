# Perl6's HTTP Router for the Pros

[![Build Status](https://travis-ci.org/tony-o/perl6-http-server-router.svg)](https://travis-ci.org/tony-o/perl6-http-server-router)

This here module provides a routing system for use with ```HTTP::Server::Async```.  It can accept named parameters (currently no restraints on what the parameter is), and hard typed paths.  Check out below for examples and usage.

## Usage

```perl6
use HTTP::Server::Async;
use HTTP::Server::Router;

my HTTP::Server::Async $server .=new;

serve $server;

route '/', sub($req, $res) {
  $res.close('Hello world!');
}

route '/:whatever', sub($req, $res) {
  $res.close($req.params<whatever>);
}

route / .+ /, sub($req, $res) {
  $res.status = 404;
  $res.close('Not found.');
}

$server.listen;
```

The example above matches a route '/' and response 'Hello world!' (complete with headers).  The other route that matches is '/<anything>' and it echos ```<anything>``` back to the client.  All other connections will hang until the client times them out.

## Notes

Routes are called in the order they're registered.  If the route's sub returns a promise, no further processing is done until that Promise is kept/broken.  If the route's sub does *not* return a Promise then a ```True``` (or anything that indicates True) value indicates that further processing should stop.  A ```False``` value means continue trying to match handlers.


## License

Do what you will.  Be careful out there amongst the English.

@tony-o
