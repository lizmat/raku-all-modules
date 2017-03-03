# EventSource::Server

A simple handler to provide Server Sent Events from HTTP::Server::Tiny / Crust applications

## Synopsis

This sends out an event with the DateTime string every second

```perl6
use EventSource::Server;
use HTTP::Server::Tiny;

my $supply = Supply.interval(1).map( { EventSource::Server::Event.new(type => 'tick', data => DateTime.now.Str) } );

my &es = EventSource::Server.new(:$supply);



HTTP::Server::Tiny.new(port => 7798).run(&es)
```

And in some Javascript program somewhere else:

```javascript
var EventSource = require('eventsource');

var v = new EventSource(' http://127.0.0.1:7798');

v.addEventListener("tick", function(e) {
    console.info(e);

}, false);
```

See also the [examples directory](examples) in this distribution.

## Description

This provides a simple mechanism for creating a source of
[Server Sent Events](https://www.w3.org/TR/eventsource/) in a
[HTTP::Server::Tiny](https://github.com/tokuhirom/p6-HTTP-Server-Tiny)
server.

The EventSource interface is implemented by  most modern web browsers and
provides a lightweight alternative to Websockets for those applications
where only a uni-directional message is required (for example for
notifications,)

## Installation

Assuming you have a working installation of Rakudo Perl 6 with eithe ```zef```
or ```panda``` installed then you should be able to install this with:

    zef install EventSource::Server

or

    panda install EventSource::Server

If you want to install this from a local copy substitute the distribution
name for the path to the local copy.

## Support

This is quite a simple module but is fairly difficult to test well without
bringing in a vast array of large and otherwise un-needed modules, so I won't
be surprised there are bugs, similarly whilst I have tested for interoperability
with the Javascript hosts that I have available to me I haven't tested against
every known host that provides the EventSource interface.

So please feel free to report any problems (or make suggestions,) to https://github.com/jonathanstowe/EventSource-Server/issues

## Copyright and Licence

This is free software, please see the [LICENCE](LICENCE) file in the distributiuon.

© Jonathan Stowe 2017


