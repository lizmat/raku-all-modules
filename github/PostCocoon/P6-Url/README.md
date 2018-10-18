TITLE
=====

PostCocoon::Url

SUBTITLE
========

Some simple but useful URL utils

SYNOPSIS
========

A collection of functions that can be used for URL parsing, building and changing.

Also provides an loose URL tokenizer

### sub url-encode

```perl6
sub url-encode(
    Str $data
) returns Str
```

Transforms an string into an percent encoded string

### sub url-decode

```perl6
sub url-decode(
    Str $data
) returns Str
```

Transforms an percent encoded string into an plain string

### sub build-query-string

```perl6
sub build-query-string(
    Hash $hash
) returns Str
```

Build an query string from an Hash

### sub build-query-string

```perl6
sub build-query-string(
    *%hash
) returns Str
```

Build an query string from the named arguments

### sub parse-query-string

```perl6
sub parse-query-string(
    Str $query-string
) returns Hash
```

Parse a query string

class PostCocoon::Url::URL-Parser
---------------------------------

Loose URL parser that doesn't follow RFC3986 not completly.

### sub is-valid-url

```perl6
sub is-valid-url(
    Str $uri
) returns Bool
```

Check if something is a valid url according to the parser

### sub parse-url

```perl6
sub parse-url(
    Str $uri
) returns Hash
```

Return an hash with all items of the url

### sub build-url

```perl6
sub build-url(
    Hash $hash
) returns Str
```

Build an url from given hash, this function does no error checking at all, it may result in an invalid url

### sub build-url

```perl6
sub build-url(
    *%hash
) returns Str
```

Build an url from given named parameters, this function does no error checking at all, it may result in an invalid url

