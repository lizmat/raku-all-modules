NAME
====

HTTP::Request::FormData - handler to expedite the handling of multipart/form-data requests

SYNOPSIS
========

    use HTTP::UserAgent;
    use HTTP::Request::Common;

    my $ua = HTTP::UserAgent.new;

    my $fd = HTTP::Request::FormData.new;
    $fd.add-part('username', 'alice');
    $fd.add-part('avatar', 'alice.png'.IO, Content-Type => 'image/png');

    my $req = POST(
        'http://example.com/',
        Content-Type => $fd.content-type,
        content => $fd.content,
    );

    my $res = $ua.request($req);

DESCRIPTION
===========

This provides a structured object for use with [HTTP::Request](HTTP::Request) that serializes into a nice neat content buffer.

I wrote this as an expedient work-around to some encoding issues I have with the way [HTTP::Request](HTTP::Request) works. This may be a better way to solve that problem than the API ported form LWP in Perl 5, but I am not making a judgement in that regard. I was merely attempting to expedite a solution and sharing it with the hope that it might be useful to someone else as well.

That said, this module aims at correctly rendering multipart/form-data content according to the specification laid out in RFC 7578.

METHODS
=======

method new
----------

    multi method new() returns HTTP::Request::FormData:D

Constructs a new, empty form data object.

method add-part
---------------

    multi method add-part(Str:D $name, IO::Path $file, Str :$content-type, Str :$filename)
    multi method add-part(Str:D $name, IO::Handle $file, Str :$content-type, Str :$filename)
    multi method add-part(Str:D $name, $value, Str :$content-type, Str :$filename)

These methods append a new part to the end of the object. Three methods of adding parts are provided.

Passing an [IO::Path](IO::Path) will result in the given file being slurped automatically. The part will be read as binary data unless you specify a `$content-type` that starts with "text/".

Similarly, an [IO::Handle](IO::Handle) may be passed and the contents will be slurped from here as well. This allows you control over whether to set the binary flag or not yourself.

Finally, you can pass an explicit value, which can be pretty much any string, blob, or other cool value you like.

In each case, you can specify the `$filename` to use for that part. Note that the `$filename` will be inferred from the given path if an [IO::Path](IO::Path) is passed.

method parts
------------

    method parts() returns Seq:D

Returns a [Seq](Seq) of the parts. Each part is returned as a HTTP::Request::FormData::Part object, which provides the following accessors:

  * * `name` This is the name of the part.

  * * `filename` This is the filename of the part (if it is a file).

  * * `content-type` This is the content type to use (if any).

  * * `value` This is the value that was set when the part was added.

  * * `content` This is the content that will be rendered with the part (derived from the `value` with headers at the top).

method boundary
---------------

    method boundary() returns Str:D

This is an accessor that allows you to see what the boundary will be used to separate the parts when rendered. This boundary meets the requirements of RFC 7578, which stipulates that the boundary must not be found in the content contained within any of the parts. This means that if you add a new part, the boundary may have to change.

For this reason, the `add-part` method will throw an exception if you attempt to add a part after calling this method to select a boundary.

method content-type
-------------------

    method content-type() returns Str:D

This is a handy helper for generating a MIME type with the boundary parameter like this:

    use HTTP::Request::Common;

    my $fd = HTTP::Request::FormData.new;
    $fd.add-part('name', 'alice');

    my $req = POST(
        'http://example.com/',
        Content-Type => $fd.content-type,
        content => $fd.content,
    );

It is essentially equivalent to:

    qq<multipart/formdata; boundary=$fd.boundary()>

As this calls `boundary()`, calls to `add-part` will throw an exception after the first call to this method is made.

method content
--------------

    method content() returns Blob:D

This will return the serialized data associated with this form data object. Each part will have it's headers and content rendered in order and separated by the boundary as specified in RFC 7578.

