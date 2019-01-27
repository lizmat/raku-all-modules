## Image::Libexif

Image::Libexif - An interface to libexif.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Image-Libexif.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Image-Libexif)  | Travis CI |

## Example

High-level interface:

```Perl6
use v6;

use Image::Libexif :tagnames;
use Image::Libexif::Constants;

#| Prints all the EXIF tags
sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my Image::Libexif $e .= new: :$file;
  my @tags := $e.alltags: :tagdesc;
  say @tags».keys.flat.elems ~ ' tags found';
  for ^EXIF_IFD_COUNT -> $group {
    say "Group $group: " ~ «'Image info' 'Camera info' 'Shoot info' 'GPS info' 'Interoperability info'»[$group];
    for %(@tags[$group]).kv -> $k, @v {
      say "%tagnames{$k.Int}: @v[1] => @v[0]";
    }
  }
}
```

```Perl6
use v6;

use Concurrent::File::Find;
use Image::Libexif;
use Image::Libexif::Constants;

#| This program displays the EXIF date and time for every file in a directory tree
sub MAIN($dir where {.IO.d // die "$dir not found"})
{
  my @files := find $dir, :extension('jpg'), :exclude-dir('thumbnails') :file, :!directory;
  @files.race.map: -> $file {
      my Image::Libexif $e .= new: :file($file);
      try say "$file " ~ $e.lookup(EXIF_TAG_DATE_TIME_ORIGINAL); # don't die if no EXIF is present
      $e.close;
    }
}
```

Raw interface:

```Perl6
use v6;

use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeHelpers::Blob;

#| This program extracts an EXIF thumbnail from an image and saves it into a new file (in the same directory as the original).
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my $l = exif_loader_new() // die ’Can't create an exif loader‘;
  # Load the EXIF data from the image file
  exif_loader_write_file($l, $file);
  # Get the EXIF data
  my $ed = exif_loader_get_data($l) // die ’Can't get the exif data‘;
  # The loader is no longer needed--free it
  exif_loader_unref($l);
  $l = Nil;
  if $ed.data && $ed.size {
    my $thumb-name = $file;
    $thumb-name ~~ s/\.jpg/_thumb.jpg/;
    my $data = blob-from-pointer($ed.data, :elems($ed.size), :type(Blob));
    spurt $thumb-name, $data, :bin;
  } else {
    say "No EXIF thumbnail in file $file";
  }
  # Free the EXIF data
  exif_data_unref($ed);
}
```

For more examples see the `example` directory.

## Description

Image::Libexif provides an interface to libexif and allows you to access the EXIF records of an image.

For more details on libexif see L<https://github.com/libexif> and L<https://libexif.github.io/docs.html>.

## Documentation

#### use Image::Libexif;
#### use Image::Libexif :tagnames;

If asked to import the additional symbol `tagnames`, Image::Libexif will make available the Hash %tagnames, which
has tag numbers as keys and a short description as values.

#### new()
Creates an Image::Libexif object.

If the optional argument `$file` is provided, then it will be opened and read; if not provided
during the initialization, the program may call the `open` method later.
If the optional argument `data` is provided, then the object will be initialized from the provided data; if not
provided during the initialization, the program may call the `load` method later.

#### open(Str $file!)
Opens a file and reads it into an initialiazed object (when no file or data has been provided during initialization).

#### load(Buf $data!)

Reads the data into an initialiazed object (when no file or data has been provided during initialization).

#### close

Closes the internal libexif object, frees the memory and cleans up.

#### info(--> Hash)

Gathers some info:

* `ordercode`: the byte order as a code
* `orderstr`:  the byte order as a string
* `datatype`:  the data type
* `tagcount`:  the number of tags

#### lookup(Int $tag!, Int $group! --> Str)
#### lookup(Int $tag! --> Str)

Looks up a tag in a specific group or in all groups. A tag may be present in more than one group.
Group names are available as constants:

* `IMAGE_INFO`
* `CAMERA_INFO`
* `SHOOT_INFO`
* `GPS_INFO`
* `INTEROPERABILITY_INFO`

#### tags(Int $group! where 0 <= * < 5, :$tagdesc? --> Hash)

Delivers all the tags in a specific group into a hash; the keys are the tag numbers.
If the tag description is requested, the hash values are presented as an array [value, tag description].

#### alltags(:$tagdesc? --> Array)

Delivers an array of hashes, one for each group.
If the tag description is requested, the hash values are presented as an array [value, tag description].

#### notes(--> Array)

Reads the Maker Note data as an array of strings.
Each string is a concatenation of the note description, name, title, and value.

#### method thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob)
#### sub thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob) is export(:thumbnail)

Returns the thumbnail found in the original file, if any, as a Blob.
This functionality is available as a method and a sub, since the library doesn't really need a fully initialized
exif object.
To use the sub import it explicitly: `use Image::Libexif :thumbnail;`.

#### Errors

There one case when an error may be returned: trying to open a non-existent file.
This can happen while initializing an object with .new() and calling the .open() method.
In both cases the method will return a Failure object, which can
be trapped and the exception can be analyzed and acted upon.

## Prerequisites
This module requires the libexif library to be installed. Please follow the instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libexif12
```

The module looks for a library called libexif.so.

## Installation

To install it using zef (a module management tool):

```
$ zef update
$ zef install Image::Libexif
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

## Note

Image::Libexif relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl6 module.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
