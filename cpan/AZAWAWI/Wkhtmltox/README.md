# Wkhtmltox

 [![Build Status](https://travis-ci.org/azawawi/perl6-wkhtmltox.svg?branch=master)](https://travis-ci.org/azawawi/perl6-wkhtmltox) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-wkhtmltox?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-wkhtmltox/branch/master)

This modules converts HTML code to PDF or Image files using [`libwkhtmltox`](https://wkhtmltopdf.org/libwkhtmltox/) (aka `wkhtmltopdf`, `wkhtmltoimage`). It does not run `wkhtmltopdf` or `wkhtmltoimage` binaries thus
no extra CPU/memory cost for each conversion operation. It is suitable for batch
HTML to PDF/Image conversions.

**Note: This is currently experimental and API may change. Please DO NOT use in
a production environment.**

## Example

```perl6
use v6;
use Wkhtmltox::PDF;

# Print library version
my $version = Wkhtmltox::PDF.version;
say "wkhtmltopdf version: $version";

# Create pdf object
my $pdf = Wkhtmltox::PDF.new;

# Print global setting values
say $pdf.get-global-setting("size.pageSize");

# Set global settings values
$pdf.set-global-setting("size.pageSize", "A4");

# Convert HTML to PDF
my $html = "Perl 6 rocks!";
my $pdf-blob = $pdf.render($html);
"sample.pdf".IO.spurt($pdf-blob) if $pdf-blob.defined;

# Call only once to cleanup resources
$pdf.destroy;
```

## Installation

- Please [download](https://wkhtmltopdf.org/downloads.html) & install
  `libwkhtmltox` binaries.

- Install this module using [zef](https://github.com/ugexe/zef):

```
$ zef install Wkhtmltox
```

## Testing

- To run tests:
```
$ prove -ve "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
