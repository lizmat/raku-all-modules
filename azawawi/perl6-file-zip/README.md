## File::Zip [![Build Status](https://travis-ci.org/azawawi/perl6-file-zip.svg?branch=master)](https://travis-ci.org/azawawi/perl6-file-zip)

This module provides a [Perl 6](http://perl6.org) API to the [ZIP file format](https://en.wikipedia.org/wiki/Zip_\(file_format\)).

***Note:*** This module is a work in progress. Please see its project status [here](https://github.com/azawawi/perl6-file-zip/blob/master/README.md#project-status).

## Example

```Perl6
use File::Zip;

my $zip-file = File::Zip.new(file-name => 'test.zip');

# List the files in the archive
say $_.perl for $zip-file.files;

# Unzip the archive into given directory
$zip-file.unzip(directory => 'output');
```

For more examples, please see the [examples](examples) folder.

## Project Status

- Improve documentation
- More examples
- Get all file members API
- Extract a zip file using deflate
- Write tests

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install File::Zip
```

## Testing

To run tests:

```
$ prove -e perl6
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

Artistic License 2.0
