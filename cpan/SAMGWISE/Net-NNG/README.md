[![Build Status](https://travis-ci.org/samgwise/Net-NNG.svg?branch=master)](https://travis-ci.org/samgwise/Net-NNG)

NAME
====

Net::NNG - NanoMSG networking with libnng

SYNOPSIS
========

    use Net::NNG;

    my $url = "tcp://127.0.0.1:8887";

    my $pub = nng-pub0-open;
    nng-listen $pub, $url;

    my @clients = do for 1..8 {
        start {
            CATCH { warn "Error in client $_: { .gist }" }

            my $sub nng-sub0-open;
            nng-dial = $sub, $url;
            for 1..15 -> $client-id {
                nng-subscribe $sub, "/count";

                # Take the number at the end of the /count message
                say "Client $client-id: ", nng-recv($sub).tail.decode('utf8')
            }
            nng-close $sub
        }
    }

    my $server = start {
        CATCH { warn "Error in server: { .gist }" }

        for 1..15 {
            nng-send $pub, "/count$_".encode('utf8');
            sleep 0.5;
        }
    }

    await Promise.allof: |@clients, $server;

    nng-close $pub

DESCRIPTION
===========

Net::NNG is a NativeCall binding for [libnng](https://github.com/nanomsg/nng) a lightweight implementation of the nanomsg distributed messaging protocol. By default supported transports are inproc, IPC and IP. Additional transport layers such as TLS, Websockets and ZeroTier can be included when the library is compiled.

This is currently an early release and isn't yet feature complete but provides usable subscribe/publish, request/reply and survey/responder patterns. Other patterns currently offered by libnng such as the bus patterns are yet to be included in this interface.

This module does not yet handle providing you with a libnng library on your system so you will need to either build or install the library yourself. If you are compiling from source be sure to provide the -DBUILD_SHARED_LIBS option when building the cmake project else you will only be build static objects.

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### multi sub nng-setopt

```perl6
multi sub nng-setopt(
    Net::NNG::NNGSocket $socket,
    Str $name,
    Str $value
) returns Mu
```

Set a string option for a socket. An options enum is defined in Net::NNG::Options.

### multi sub nng-setopt

```perl6
multi sub nng-setopt(
    Net::NNG::NNGSocket $socket,
    Str $name,
    Bool $value
) returns Mu
```

Set a boolean option for a socket. An options enum is defined in Net::NNG::Options.

### multi sub nng-setopt

```perl6
multi sub nng-setopt(
    Net::NNG::NNGSocket $socket,
    Str $name,
    Int $value,
    Bool :$ms = Bool::False
) returns Mu
```

Set an integer value for an option on a socket. If the option is a millisecond value, passing the named ms flag. An options enum is defined in Net::NNG::Options.

### sub nng-subscribe

```perl6
sub nng-subscribe(
    Net::NNG::NNGSocket $socket,
    Str $header
) returns Bool
```

Set an active subscription on a socket You must subscribe with a header to receive messages on subscription socket. The header can be any string and will also be present in the blob of the received message. Returns True on success and a Failure on error.

### sub nng-req0-open

```perl6
sub nng-req0-open() returns Net::NNG::NNGSocket
```

Creates a new request (version 0) socket for making requests to a reply socket. Returns a NNGSocket pointer or Failure on error.

### sub nng-rep0-open

```perl6
sub nng-rep0-open() returns Net::NNG::NNGSocket
```

Creates a new reply (version 0) socket for responding to requests. Returns a NNGSocket pointer or Failure on error.

### sub nng-pub0-open

```perl6
sub nng-pub0-open() returns Net::NNG::NNGSocket
```

Create a new publish (version 0) socket for sending to subscribers. Returns a NNGSocket pointer or failure on error.

### sub nng-sub0-open

```perl6
sub nng-sub0-open() returns Net::NNG::NNGSocket
```

Create a new socket for subscribing to a publisher socket. Returns a NNGSocket pointer or failure on error.

### sub nng-survey-duration

```perl6
sub nng-survey-duration(
    Net::NNG::NNGSocket $socket,
    Int $duration
) returns Bool
```

Set survey duration on a socket. This function accepts a duration in milliseconds. Returns True on success and a Failure on error.

### sub nng-surveyor0-open

```perl6
sub nng-surveyor0-open() returns Net::NNG::NNGSocket
```

Create a new socket for handling survey (version 0) requests. Use nng-listen to attach this socket to a protocol and address.

### sub nng-respondent0-open

```perl6
sub nng-respondent0-open() returns Net::NNG::NNGSocket
```

Create a respondent (version 0) socket for replying to surveys. use nng-listen to attach this socket to a protocol and address.

### sub nng-listen

```perl6
sub nng-listen(
    Net::NNG::NNGSocket $socket,
    Str $url
) returns Bool
```

Start listening on a socket. Returns True on success or Failure on error. Valid URLs will vary depending on the features your libnng is compiled for. At the time of writing tcp, ipc, among others are supported by default. Additional dependencies are required for secure protocols such as https, wss. Additional dependencies are also required for XeroTier Networking. Check the nng docs for more details.

### sub nng-dial

```perl6
sub nng-dial(
    Net::NNG::NNGSocket $socket,
    Str $url
) returns Bool
```

Connects the given socket to a listening socket at the URL provided. Returns True on success and Failure on error. See nng-listen for a discussion of transports.

### sub nng-recv

```perl6
sub nng-recv(
    Net::NNG::NNGSocket:D $socket
) returns Blob
```

Receives messages on a socket. Returns a Blob of the message on success or a Failure on error.

### sub nng-send

```perl6
sub nng-send(
    Net::NNG::NNGSocket:D $socket,
    Blob $message
) returns Bool
```

Sends a Blob with the socket provided. Returns True on success or Failure on error.

