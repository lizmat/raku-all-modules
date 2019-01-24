# Examples for EventSource::Server

This directory contains some short examples of the ways that this module can be used.

There is also a small node.js client that can be used to exercise the examples
from the command line.

Most of the examples require [HTTP::Server::Tiny](https://github.com/tokuhirom/p6-HTTP-Server-Tiny)
which can be installed with

	zef install HTTP::Server::Tiny


## [tick-server](tick-server)

This sends a "tick" event wuth the Date time every second.


## [cro-tick-server](cro-tick-server)

This implements the [tick-server](tick-server) as above, but using [Cro](https://cro.services/) 
instead of HTTP::Server::Tiny which can be installed with:

    zef install --/test cro

## [amqp-bridge](amqp-bridge)

This demonstrates bridging an AMQP message queue to an EventSource, you will need an AMQP broker
such as RabbitMQ and [Net::AMQP](https://github.com/retupmoca/P6-Net-AMQP) which can be
installed with

    zef install Net::AMQP

