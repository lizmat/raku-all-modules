# Tika

 [![Build Status](https://travis-ci.org/azawawi/p6-tika.svg?branch=master)](https://travis-ci.org/azawawi/p6-tika) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/p6-tika?svg=true)](https://ci.appveyor.com/project/azawawi/p6-tika/branch/master)

This is a Perl 6 library for using the [Apache Tika](http://tika.apache.org/)
Server REST API. Apache Tika server JAR is already included. You just need to
install Java runtime or JDK to be able to use it.

## Example

```perl6
use v6;
use Tika;

my $t = TikaWrapper.new;
$t.start;

say "Found {$t.version} server";

say $t.parsers;
say $t.detectors;

my $filename     = 'demo.docx';
my $content-type = $t.mime-type($filename);
say "Detected stream type $content-type";

my $metadata = $t.meta($filename, $content-type);
say "Metadata for $filename:\n{$t._truncate($metadata, 40)}";

my $text = $t.text($filename, $content-type);
say "Found {$text.chars} plain text";

my $language = $t.language($text);
say "Detected language #{$language}";
```

For more examples, please take a look at [examples](examples).

## Dependencies

Please follow the instructions for your platform to be able to install Java:

|Platform|Installation command|
|-|-|
|Debian|`apt-get install default-jre`|
|macOS|`brew tap caskroom/versions`<br>`brew cask install java8`|
|Windows|Install Oracle 8 Java SE from [here](https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html).|

## Installation

- Install this module using [zef](https://github.com/ugexe/zef):

```
$ zef install Tika
```

## Testing

- To run tests:
```
$ AUTHOR_TESTING=1 zef test --verbose .
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## See Also
- [Apache Tika Server API](https://wiki.apache.org/tika/TikaJAXRS).

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6.

## License

[MIT License](LICENSE.md)
