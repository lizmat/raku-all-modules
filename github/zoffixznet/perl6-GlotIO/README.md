[![Build Status](https://travis-ci.org/zoffixznet/perl6-GlotIO.svg)](https://travis-ci.org/zoffixznet/perl6-GlotIO)

# NAME

GlotIO - use glot.io API via Perl 6

# SYNOPSIS

```perl6
use GlotIO;
my GlotIO $glot .= new: :key<89xxxx9f-a3ec-4445-9f14-6xxxe6ff3846>;

say $glot.languages;
```

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [KEY](#key)
- [METHODS](#methods)
    - [`.new`](#new)
    - [`.languages`](#languages)
    - [`.versions`](#versions)
    - [`.run`](#run)
    - [`.stdout`](#stdout)
    - [`.stderr`](#stderr)
    - [`.list`](#list)
    - [`.create`](#create)
    - [`.get`](#get)
    - [`.update`](#update)
    - [`.delete`](#delete)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# DESCRIPTION

This module lets you use API provided [glot.io](http://glot.io) which is
a pastebin that also lets you execute code in a number of languages.

# KEY

Some parts of the API require you register at glot.io and [obtain an
API key](https://glot.io/api)

# METHODS

## `.new`

```perl6
my GlotIO $glot .= new: :key<89xxxx9f-a3ec-4445-9f14-6xxxe6ff3846>;
```

Constructs and returns a new `GlotIO` object. Takes one **optional**
argument: `key`, which is [the API key](https://glot.io/api).
Methods that require the key are marked as such.

## `.languages`

```perl6
say "Glot.io supports $_" for $glot.languages;
```

Returns a list of languages supported by GlotIO.

## `.versions`

```perl6
say "Glot.io supports $_ version of Perl 6"
    for $glot.versions: 'perl6';
```

Returns a list of supported versions for a language that
must be supplied as the mandatory positional argument. List of valid
language names can be obtained via `.languages` method. Using an
invalid language will `fail` an an HTTP 404 error.

## `.run`

```perl6
    say $glot.run: 'perl6', 'say "Hello, World!"';

    say $glot.run: 'perl6', [
        'main.p6' => 'use lib "."; use Foo; doit;',
        'Foo.pm6' => 'unit module Foo; sub doit is export { say "42" }',
    ];

    say $glot.run: 'python', 'print "Hello, World!"', :ver<2>;
```

Requests code to run on Glot. The first positional argument specifies
the language to use (see `.languages` method). Second argument
can either be an `Str` of code to run or an `Array` of `Pair`s. If the
array is specified, the key of each `Pair` specifies the filename and
the value specifies the code for that file. The first file in the
array will be executed by Glot, while the rest are supporting files,
such as modules loaded by the first file.

The optional named argument `ver` can be used to specify the version
of the language to use. See `.versions` method.

Returns a `Hash` with three keys: `stdout`, `stderr` which specify
the output streams received from the program and `error` that
seems to contain an error code, if the program doesn't successfully
exit.

If an incorrect language or version are specified, will `fail` with
an HTTP 404 error.

## `.stdout`

```perl6
    say $glot.stdout: 'perl6', 'say "Hello, World!"';
```

A shortcut for calling `.run` (takes same arguments) and returning
just the `stdout` key. Will `fail` with the entire `Hash` returned
from `.run` if the program errors out.

## `.stderr`

```perl6
    say $glot.stderr: 'perl6', 'note "Hello, World!"';
```

A shortcut for calling `.run` (takes same arguments) and returning
just the `stderr` key. Will `fail` with the entire `Hash` returned
from `.run` if the program errors out.

## `.list`

```perl6
say $glot.list<content>[0..3];

say $glot.list: :3page, :50per-page, :mine;
```

Fetches a list of metadata for snippets. Takes optional
named arguments:

* `page` positive integer starting at and defaulting to 1. Specifies the page to display
* `per-page` positive integer stating the maximum number of items to return per
page. Defaults to `100`. Maximum value is `100`.
* `mine` boolean specifying whether public or your own snippets should be
listed. Defaults to `False`. Requires `key` argument to `.new` to be provided
if set to `True`.

Returns a `Hash` in the following format:

```perl6
    {
        first   => 1,
        last    => 20,
        next    => 5,
        prev    => 3,
        content => [
            {
                created    => "2016-04-09T17:52:19Z",
                files_hash => "2afa1f37cc0bc7d033e4b3a049659792f5caac6d",
                id         => "edltstt3n0",
                language   => "cpp",
                modified   => "2016-04-09T17:52:19Z",
                owner      => "anonymous",
                public     => Bool::True,
                title      => "Untitled",
                url        => "https://snippets.glot.io/snippets/edltstt3n0",
            },
            ...
        ]
    }
```

The `first`, `last`, `next`, `prev` keys indicate the corresponding page number.
All 4 will NOT be present at all times. The `content` key is a list of hashes,
each representing metadata for a snipet.

Attempting to fetch a page that doesn't exist will `fail` with an HTTP 404
error.

## `.create`

```perl6
    say $glot.create: 'perl6', 'say "Hello, World!"';

    say $glot.create: 'perl6', [
            'main.p6' => 'use lib "."; use Foo; say "Hello, World!"',
            'Foo.pm6' => 'unit module Foo;',
        ], 'Module import example',
        :mine;
```

Creates a new snippet.
Takes: a valid language (see `.languages` method), either a `Str` of code
or an array of `filename => code` pairs, and an optional title of the snippet
as positional arguments. An optional `Bool` `mine` named argument, which
defaults to `False` can be set to `True` to specify your snippet should not
be public. API Key (see `.key` in `.new`) must be specified for this option
to succeed.

Returns a hash with metadata for the newly created snippet:

```perl6
    {
      created    => "2016-04-10T17:42:20Z".Str,
      files      => [
        {
          content => "say \"Hello, World!\"".Str,
          name    => "main".Str,
        },
      ],
      files_hash => "6ed47f09569b36dc8d83b6af82026e5f86e3967e".Str,
      id         => "edmx7tewwu".Str,
      language   => "perl6".Str,
      modified   => "2016-04-10T17:42:20Z".Str,
      owner      => "c490baa3-1ecb-42f5-8742-216abbb97f8d".Str,
      public     => Bool::False.Bool,
      title      => "Untitled".Str,
      url        => "https://snippets.glot.io/snippets/edmx7tewwu".Str,
    }
```

## `.get`

```perl6
    say $glot.get: 'edmxttmtd5';
```

Fetches a snippet. Takes one mandatory argument: the ID of the snippet
to fetch. Returns a hash with the snippet details:

```perl6
    {
      created    => "2016-04-10T18:04:30Z".Str,
      files      => [
        {
          content => "use lib \".\"; use Foo; say \"Hello, World!\"".Str,
          name    => "main.p6".Str,
        },
        {
          content => "unit module Foo;".Str,
          name    => "Foo.pm6".Str,
        },
      ],
      files_hash => "8042cf6813f1772e63c8afd0a556004ad9591ce2".Str,
      id         => "edmxttmtd5".Str,
      language   => "perl6".Str,
      modified   => "2016-04-10T18:04:30Z".Str,
      owner      => "c490baa3-1ecb-42f5-8742-216abbb97f8d".Str,
      public     => Bool::True.Bool,
      title      => "Module import example".Str,
      url        => "https://snippets.glot.io/snippets/edmxttmtd5".Str,
    }
```

## `.update`

```perl6
    say $glot.update: 'snippet-id', 'perl6', 'say "Hello, World!"';

    # Or
    say $glot.update: 'snippet-id', 'perl6', [
            'main.p6' => 'use lib "."; use Foo; say "Hello, World!"',
            'Foo.pm6' => 'unit module Foo;',
        ], 'Module import example';

    # Or
    my $snippet = $glot.get: 'edmxttmtd5';
    $snippet<title> = 'New title';
    $glot.update: $snippet;
```

Updates an existing snippet. Requires the use of API key (see `.key` in
constructor). As positional arguments, takes snippet ID to update,
the language of the snippet, snippet code, and snippet title.
The title is optional and will be set to `Untitled` by default.
Snippet code can be provided as a single string of code or as an array
of `Pair`s, where the key is the filename and the value is the code
for the file.

In addition, `.update` can also take a `Hash`. This form is useful
when you already have a snippet `Hash` from `.create` or `.get`
methods and simply wish to modify it. The required keys in the
hash are `id`, `title`, `language`, and `files`, where the
first three are strings and `files` is an array of Hashes, with
each hash having keys `name` and `content` representing the
filename of a file and its code.

Returns a `Hash` with the updated snippet data:

```perl6
    {
        created    => "2016-04-10T18:04:30Z".Str,
        files      => [
          {
            content => "use lib \".\"; use Foo; say \"Hello, World!\"".Str,
            name    => "main.p6".Str,
          },
          {
            content => "unit module Foo;".Str,
            name    => "Foo.pm6".Str,
          },
        ],
        files_hash => "8042cf6813f1772e63c8afd0a556004ad9591ce2".Str,
        id         => "edmxttmtd5".Str,
        language   => "perl6".Str,
        modified   => "2016-04-13T00:05:02Z".Str,
        owner      => "c490baa3-1ecb-42f5-8742-216abbb97f8d".Str,
        public     => Bool::False.Bool,
        title      => "New title".Str,
        url        => "https://snippets.glot.io/snippets/edmxttmtd5".Str,
    }
```

## `.delete`

```perl6
    $glot.delete: 'snippet-id';
```

Deletes a snippet. Requires the use of API key (see `.key` in
constructor). Takes one positional argument: the ID of the
snippet to delete. On success, returns `True`. Attempting
to delete a non-existant snippet will `fail` with an
HTTP 404 error.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-GlotIO

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-GlotIO/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
