NAME
====

MQ::Posix - Perl 6 interface for POSIX message queues

SYNOPSIS
========

    use MQ::Posix;

    my $queue = MQ::Posix.new(name => 'test-queue', :create, :r );

    react {
        whenever $queue.Supply -> $buf {
            say $buf.decode;
        }
        whenever signal(SIGINT) {
            $queue.close;
            $queue.unlink;
            done;
        }
    }

And in some separate process:

    use MQ::Posix;

    my $queue = MQ::Posix.new(name => 'test-queue', :create, :w );

    await $queue.send("some test message", priority => 10);

    $queue.close;

DESCRIPTION
===========

POSIX message queues offer a mechanism for processes to reliably exchange data in the form of messages

The messages are presented as a priority ordered queue with higher priority messages being delivered first and messages of equal priority being delivered in age order.

The mechanism is simple, having no provision for message metadata and so forth and whilst reliable, unread messages do not persist beyond the lifetime of the running kernel.

METHODS
=======

method new
----------

    method new(Str :$name!, Bool :$r, Bool :$w, Bool :$create, Bool :$exclusive, Int :$max-messages, Int :$message-size, Int :$mode = 0o660)

The constructor of the class, `$name` is the name of the queue and is required, there may be different constraints on the name in different implementations but in both **Linux** and **FreeBSD** it must conform to the requirements of a filename. On or both of `r` or `w` must be provided to indicate whether the queue should be readable, writable or both. If `create` is supplied the queue will be created if necessary, otherwise if the queue doesn't exist an exception will be thrown. If `exclusive` is supplied along with `create` an exception will be thrown if the queue already exists. `$mode` will be used as the mode of the queue if the queue is to be created, after the application of the user file creation mask in effect.

`$max-messages` and `$message-size` will be used to set the queues attributes if it is created if provided, otherwise the system defaults will be used. The system defaults may differ from system to system. If the user is not privileged and the values are higher than the configured limits then an exception may be thrown when the queue is created - how to determine the limits may differ from system to system, on Linux they can be obtained and set through a `sysctl` interface (or via `/proc/sys/fs/mqueue/` )

The queue itself may not be created immediately but rather when it first needs to be used, so any exception may not be thrown at the time the constructor is called.

method attributes
-----------------

    method attributes(--> MQ::Posix::Attr)

This returns an object describing the queue's attributes, they can't be changed after the queue is created. The object has the attributes `message-size` which is the allowed maximum size of a message, `max-messages` is the maximum number of messages allowed in the queue simulataneously and `current-messages` the number of messages in the queue.

method send
-----------

    multi method send(Str $msg, Int $priority = 0 --> Promise)
    multi method send(Buf $msg, Int $priority = 0 --> Promise)
    multi method send(CArray $msg, Int $length, Int $priority = 0 --> Promise)

If the queue is opened for writing this will send the supplied message with the specified priority, returning a Promise that will be kept when the message is placed on the queue (as it may block if there are `max-messages` alreadt on the queue.) The Promise will be broken with an exception if the queue is not opened for writing or if the message is longer than `message-size`.

method receive
--------------

    method receive(--> Promise )

This returns a Promise that will be kept with the highest priority message from the queue as a [Buf](Buf) (you are free to decode or marshal this as you wish as there is no mechanism to convey the encoding.) it will be broken with an exception if the queue wasn't opened for reading. The message will never exceed `message-size` bytes.

method Supply
-------------

    method Supply(--> Supply)

This provides a Supply onto which are emitted the messages as a [Buf](Buf) as they arrive on the queue. An exception will be thrown if the queue isn't opened for reading. The first time this is called a new thread will be started to feed the supply which will run until the queue is closed.

In places which expect a Supply such as a `whenever` this need not be explicitly called and the object can be coerced instead,

method close
------------

    method close( --> Bool)

This closes the queue handle that will have been opened if the queue was written to or read, after this has been called an exception will be thrown if attempting to read or write. If `Supply` was called the thread it started will finish.

method unlink
-------------

    method unlink( --> Bool)

This will remove the queue and it will no longer be able to be opened by another process, any process that currently has it opened will still be able to use it, and the queue will be removed when the last opener closes it. An exception will be thrown if the queue was already removed or if the effective user doesn't have permission.
