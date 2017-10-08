[![Build Status](https://travis-ci.org/zoffixznet/perl6-NASA.svg)](https://travis-ci.org/zoffixznet/perl6-NASA)

# NAME

NASA::APOD - use NASA's `APOD: Astronomy Picture of the Day` API

# SYNOPSIS

```perl6
use NASA::APOD;
my NASA::APOD $apod .= new: :key<drH7437T55HSV266UJ77TxhoT>;

say "Astronomy Picture of the Day is $apod";
```
# DESCRIPTION

Fetch an *Astronomy Picture of The Day* for today or some day in the past.
Provides title, description, and link to view the image.

# METHODS

## `new`

```perl6
use NASA::APOD;
my NASA::APOD $t .= new; # use severely rate-limited keyless operation
my NASA::APOD $t .= new: :key<drH7437T55HSV266UJ77TxhoT>; # use your own API key
```

Constructs and returns a new `NASA::APOD` object. Takes one **optional**
argument: `key`. To get your API key, visit [](https://api.nasa.gov/index.html#apply-for-an-api-key). If no key is provided,
`DEMO_KEY` will be used, which is a rate-limited key provided by NASA. It allows
only 50 queries per day (30 per hour).

## `apod`

```perl6
    my %res = $t.apod;
    say "%res<title>: %res<hdurl>";

    $t.apod: '2014-04-04';
    $t.apod: Date.new: '2014-04-04';
    $t.apod: '2014-04-04', :hd;
```

Make an API request and returns a Hash on success. On failure, `fail`s. Takes
an optional `Str` or `Dateish` positional argument that specifies the date
to look up. If omited, today's date (as determined by the API) will be used.

An optional named `Bool` argument `hd` can be passed that specifies whether
the HD image URL should be included. At the moment, the API does not seem
to respect this parameter and HD URL is always present.

The returned Hash has the following format:

```perl6
    copyright => "Arnar Kristjansson",
    date => "2016-4-4",
    explanation => "Is this the real world?  Or is it just fantasy? ... ",
    title => "Lucid Dreaming",
    hdurl => "http://apod.nasa.gov/apod/image/1604/AuroraFalls_Kristjansson_1920.jpg",
    url => "http://apod.nasa.gov/apod/image/1604/AuroraFalls_Kristjansson_960.jpg",
    media_type => "image",
    service_version => "v1",
```

If `copyright` key is not present, the image is in the public domain.
`hdurl` points to a higher-resolution version of the image than `url` link,
but the two can be the same on some images.

## `Str`

```perl6
    say "Astronomy Picture of the Day is $apod";
```

The `.Str` method calls `.apod` and returns string `<title>: <hdurl>`

## `gist`

```perl6
    say $apod;
```

The `.gist` method calls `.apod` and returns string `<title>: <url>`

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-NASA

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-NASA/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
