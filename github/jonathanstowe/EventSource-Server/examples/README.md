# Examples for EventSource::Server

This directory contains some short examples of the ways that this module can be used.

There is also a small node.js client that can be used to exercise the examples
from the command line.

All of the examples require [HTTP::Server::Tiny](https://github.com/tokuhirom/p6-HTTP-Server-Tiny)
which can be installed with

	panda install HTTP::Server::Tiny

or

	zef install HTTP::Server::Tiny

depending on your preference.

## [tick-server](tick-server)

This sends a "tick" event wuth the Date time every second.


## [amqp-bridge](amqp-bridge)

This demonstrates bridging an AMQP message queue to an EventSource, you will need an AMQP broker
such as RabbitMQ and [Net::AMQP](https://github.com/retupmoca/P6-Net-AMQP) which can be
installed with

    panda install Net::AMQP

or

    zef install Net::AMQP


