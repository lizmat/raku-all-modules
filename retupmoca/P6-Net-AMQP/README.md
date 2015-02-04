P6-Net-AMQP
===========

Net::AMQP - a AMQP 0.9.1 client library (built and tested against RabbitMQ)

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
