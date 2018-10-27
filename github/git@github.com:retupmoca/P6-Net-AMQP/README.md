# Net::AMQP

Net::AMQP - a AMQP 0.9.1 client library (built and tested against RabbitMQ)

## Synopsis

First start a consumer that will print the received messages:

```
use v6;

use Net::AMQP;

my $n = Net::AMQP.new;

my $connection = $n.connect.result;

say 'connected';

my $channel = $n.open-channel(1).result;

say 'channel';

my $q = $channel.declare-queue('echo').result;

say 'queue';

$q.message-supply.tap({
    say 'Got message!';
    say $_.body.decode;
    if $_.body.decode eq 'exit' {
        $n.close("", "");
    }
});

say 'set up';

$q.consume;

say 'consuming';

await $connection;
```

Then run the script that will send a message sent on the command line,

```

use v6;

use Net::AMQP;

sub MAIN($message) {
    my $n = Net::AMQP.new;

    await $n.connect;

    my $channel = $n.open-channel(1).result;

    $channel.exchange.result.publish(routing-key => "echo", body => $message.encode);

    await $n.close("", "");
}

```

## Description

This is an async network library. Any -supply method returns a supply, and every
other method will return a promise (with the exception of the initial Net::AMQP.new
call).

## Methods ##

### Net::AMQP ###

 -  new

 -  close

 -  open-channel

 -  connect

### Net::AMQP::Channel ###

 -  close

 -  declare-exchange

 -  exchange

 -  declare-queue

 -  queue

 -  qos

 -  flow

 -  recover

### Net::AMQP::Exchange ###

 -  delete

 -  publish

 -  return-supply
    
    NYI

 -  ack-supply
    
    NYI

### Net::AMQP::Queue ###

 -  bind
    
 -  unbind
    
 -  purge

 -  delete

 -  consume

 -  cancel
    
    NYI

 -  message-supply

 -  recover
    
    NYI

## Installation

In order for this  to work you will need to have access to an AMQP
broker, the tests will, by default, use a broker on ```localhost```
with the default credentials.  The tests will be skipped if no
server is available,

Assuming you have a working installation of Rakudo Perl 6 then you
will be able to install this with *zef* :

    zef install Net::AMQP

    # or if you have a local copy

    zef install .


