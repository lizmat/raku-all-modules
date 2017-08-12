# deredere

Simple scraper framework for Perl 6.


## Usage

Often we need to get some data from some web page over the Internet. Some sites provide an API, but many sites don't. This framework makes building of "data scraper" easier. You can just get the whole page, or parse it and do something with data. At this stage three basic cases are handled:
- Downloading of raw page by url.
- Downloading of raw page, data parsing and handling by default operator.
- Downloading of raw pages, where next link is extracted with outer function, data parsing and handling by custom operator.

`Parser` is just outer function, that converts an XML document to some data list.

`Operator` is just outer function, that takes data list and processes it.

`Default operator`, which is used when none passed, works like that: if parsed item is a URL, it will be downloaded, if parsed item is just some text, it will be appended to file with data.


## The real example itself

```Perl6
use deredere;
use XML;

sub src-extractor($node) {
    ($node.Str ~~ /src\=\"(.+?)\"/)[0].Str;
}

sub parser($doc) {
    $doc.lookfor(:TAG<img>).race.map(&src-extractor);
}

# Just as pure example.
scrape("konachan.net/post", &parser);
```

See other examples for more info.

## Scrapers

```Perl6
sub scrape(Str $url);
sub scrape(Str $url, &parser, Str :$filename="scraped-data.txt");
# "Next" function has a default value of empty line function, in the case if we scrape the first page only.
sub scrape(Str $url, &parser, &operator, &next?, Int $gens=1, Int $delay=0);
```


## Installation

```
$ zef update
$ zef install deredere
```

Also, you can install `IO::Sockes::SSL` to work with "https" links. You also need `XML` to build effective data parsers.

## Testing

Tests are coming.

## To-do List

- Tests.
- More cases.
- More operators.
- Speed up.
