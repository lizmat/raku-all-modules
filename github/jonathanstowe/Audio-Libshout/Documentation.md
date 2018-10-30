NAME
====

Audio::Libshout - binding to the xiph.org libshout icecast source client

SYNOPSIS
========

        use Audio::Libshout;

        my $shout = Audio::Libshout.new(password => 'hackme', mount => '/foo', format => Audio::Libshout::Format::MP3);
        my $fh = @*ARGS[0].IO.open(:bin);
        my $channel = $shout.send-channel;

        while not $fh.eof {
	        my $buf = $fh.read(4096);
	        $channel.send($buf);
        }

        $fh.close;
        $channel.close;
        $shout.close;

See also the files in the `examples` directory

DESCRIPTION
===========

This provides a source client to stream to an icecast server. It can stream Ogg/Vorbis or MP3 data but doesn't provide any transcoding so the data will need to be provided from an appropriate source in the required encoding. This has been developed against version 2.2.2 of libshout, it is possible later versions may provide support for other encodings.

The API is somewhat simplified in comparison to libshout but provides an asynchronous mechanism whereby data can be fed as quickly as it is obtained to a worker thread via a channel so the client doesn't have to worry about the timing and synchronisation issues, though the lower level send and sync methods are available if your application requires a different scheme.

In testing this proved quite capable of streaming a 320kb/s MP3 read from a file to an icecast server on the local network, though of course network conditions may limit the rate that will work well to remote servers.

The "examples" directory in the distribution contains a simple streaming source client that will allow you to send an Ogg or MP3 file to an icecast server.

If you're curious the first thing that I streamed using this library was

https://www.mixcloud.com/mikestern-awakening/mike-stern-guest-mix-for-technotic-eire-radio-show/

Mike's a great DJ, great DJs and producers make making software worthwhile :)

METHODS
=======

method new
----------

    method new(*%params) returns Audio::Libshout

The object constructor can be passed any of the parameters described in [STREAM PARAMETERS](STREAM PARAMETERS). It may throw an [X::ShoutError](X::ShoutError) if there was a problem initialising the library or setting any of the parameters.

The [Audio::Libshout](Audio::Libshout) object returned will be initialised but not connected to the server, the connection should be made before any data is sent to the server.

method open
-----------

    method open()

If the stream is not already connected this will open the stream so that data can be sent. The `host`, `port`, `user` and `password` and other parameters that may be required by the protocol must be set before calling `open`. If a connection cannot be made to the server or the server refuses the connection (e.g. due to an authentication failure,) a [X::ShoutError](X::ShoutError) will be thrown.

This will be called for you the first time that `send` is called or the first data is sent to the `send-channel` however you may wish to call it early in order to detect and rectify any problems.

method close
------------

    method close()

This will close the connection to the server. It will wait for the worker thread that is started by `send-channel` to complete, which will not happen until the [Channel](Channel) is closed so you should always call `close` on the channel to indicate that no more data will be sent.

method send
-----------

    multi method send(Buf $buf)
    multi method send(CArray[uint8], Int $bytes);
    multi method send(RawEncode $raw);

This will send the [Buf](Buf) of unsigned chars ([uint8](uint8),) to the server. The buffer must contain data encoded as per that set for `format` (i.e. either `Ogg` or `MP3` ) If there is a problem sending the data to the server then a [X::ShoutError](X::ShoutError) will be thrown. If `open` has not already been called it will be called for you and this may also throw an exception. The data will be sent immediately so `sync` should be called between each attempt to send or an exception may be thrown indicating that the server is busy.

The second multi variant is intended to make interoperation with other libraries which may return encoded data in a `CArray`. The third is similar but accepts an `Array` of two elements the first being a `CArray[uint8]` and the second an `Int` which is the number of bytes in the array, this reflects the return value of the `encode` methods of [Audio::Encode::LameMP3](Audio::Encode::LameMP3) with the `:raw` adverb. This is intended to reduce the marshalling required when there is no need to have the data in perl space.

If you don't want to be concerned with the synchronisation issues then you should consider the asynchronous interface provided by `send-channel`.

method sync
-----------

    method sync()

This will block the thread of execution until the server is ready to accept new data. It should be called between each call to `send` in order to maintain the rate of data transfer correctly. A `send` that is made without a preceding `sync` may throw an exception indicating that the server is busy.

If you don't want to be concerned with the synchronisation issues then you should consider the asynchronous interface provided by `send-channel`.

method send-channel
-------------------

    multi method send-channel() returns Channel
    multi method send-channel(Channel $channel) returns Channel

This provides an asynchronous mechanism that allows a client to send data to a [Channel](Channel) as it becomes available, being processed by a helper thread that will take care of the synchronisation. This should be considered the preferred interface for most applications.

If `open` has not already been called then it will be done for you the first time that data is received on the [Channel](Channel), as with `open` an exception will be thrown if a connection cannot be made or the server refuses the connection.

As with `send` the data sent to the [Channel](Channel) should be a [Buf](Buf) of unsigned chars ([uint8](uint8)). If data of another type is sent on the channel then an exception will be thrown in the worker thread. The data can also be Array of two elements: a `CArray[uint8]` and an `Int` that is the number of bytes in that `CArray` as described under `send` above.

This can be provided with an existing [Channel](Channel) that may be useful if the data originates from another asynchronous source for example.

The worker thread will be started immediately that this method is called and will remain active until the channel is closed, consequently a subsequent call to `close` will wait until the thread is finished to allow all the sent data to be transmitted to the server.

The "streamfile" program in the repository provides an example of the use of this interface.

add-metadata
------------

    multi method add-metadata(Str $key, Str $value)
    multi method add-metadata(*%metas)

This provides a means to set the metadata on the stream, it only works for streams of format `MP3`. The exact meaning of any particular metadata item is specific to the client of the stream.

The metadata items are added to or updated in a private metadata structure, that can be applied to the stream with `set-metadata`, for convenience if the metadata is supplied in the second form (i.e like named arguments,) this will be done for you.

This may throw a [X::ShoutError](X::ShoutError) if the metadata structure is invalid.

set-metadata
------------

    method set-metadata()

This will send the metadata as added or updated by `add-metadata` to the connected stream. This will only work if the format of the stream is `MP3`.

It will throw a [X::ShoutError](X::ShoutError) if an error is encountered while setting the metadata.

libshout-version
----------------

This will return a [Version](Version) object that represents the version of the `libshout` that is being used.

STREAM PARAMETERS
=================

These can all be supplied to the constructor as named arguments or set as attributes on a new object, some provide sensible defaults which are noted and some are required and must be set before the stream is opened. Setting a parameter that doesn't make sense given the state of the stream or already set parameters will result in a [X::ShoutError](X::ShoutError) being thrown.

host 
-----

The hostname or IP address of the streaming server. The default is 'localhost'.

port 
-----

The port number on which the server is listening. The default is 8000

user 
-----

The username that is used to authenticate against the server, the default is 'source'. If the `protocol` is set to `ICY` then setting this makes no sense as 'source' is always used.

password 
---------

The password that is used to authenticate with the server. There is no default and this must be provided before connecting.

protocol 
---------

A value of the `enum` [Audio::Libshout::Protocol](Audio::Libshout::Protocol) indicating which protocol should be used to communicate with the server:

  * HTTP

This is the Icecast v2 protocol and the default, this should be used unless there is a  compelling reason to do otherwise.

  * XAUDIOCAST

The protocol used by version 1 of Icecast.

  * ICY

The Shoutcast protocol. If this is used then there are certain constraints on other parameters, it should only be used if you are using an actual Shoutcast server.

format 
-------

The encoding format that is to be sent as a value of the `enum` [Audio::Libshout::Format](Audio::Libshout::Format) - the default is `Ogg`. No transcoding is done so the data to be sent to the server must be in the configured format - the result of setting a different format to the actual format of the data is that you will get an unreadable stream. Later versions of `libshout` might provide for further formats.

  * MP3

  * Ogg

mount 
------

The "mount point" (i.e. the path part ) on the server that represents this stream. There is no default. The `ICY` protocol does not support setting this. On setting this will be "normalised" with a leading '/' (e.g. setting "stream" will return "/stream".)

dumpfile 
---------

This can be set to cause an archive of the stream to be made on the server with the provided name. The server may not support this (or may configured to allow it.) The resulting file will be at least as large as the streamed data and if the server runs out of disk space it may interrupt the stream, so think carefully before using this.

agent 
------

This is the UserAgent header that is sent for the `HTTP` protocol. The default is "libshout/$version".

public 
-------

This is a [Bool](Bool) that indicates whether the server should list the stream in any directory services that it has configured. The default is `False`.

name 
-----

The stream name that should be used in a directory listing. This may also be passed on to connected clients. There is no default.

url 
----

The stream URL that should be used in a directory listing. This may also be passed on to connected clients. There is no default.

genre 
------

The genre of the stream that should be used in a directory listing. This may also be passed on to connected clients. There is no default.

description
-----------

A description of the stream that should be used in a directory listing. This may also be passed on to connected clients. There is no default.
