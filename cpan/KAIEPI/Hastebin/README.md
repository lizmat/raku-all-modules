NAME
====

Hastebin - Hastebin client API

SYNOPSIS
========

    use Hastebin;

    my Str $url = Hastebin.post: 'ayy lmao';
    my Str $res = Hastebin.get:  $url;
    say $res; # ayy lmao

DESCRIPTION
===========

Hastebin is a Hastebin client API. This can be used to get data from Hastebin and post data to Hastebin.

METHODS
=======

  * **get**(Str *$url* --> Str)

Fetches the content at the given URL. `$url` may be the Hastebin key, a partial URL, or a full URL.

  * **post**(Str *$content* --> Str)

Posts the given text to Hastebin and returns the URL for the raw paste.

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

