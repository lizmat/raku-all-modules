# Archive::SimpleZip

Perl6 module to write Zip archives.

## Synopsis


```

use Archive::SimpleZip;

# Create a zip file in filesystem
my $obj = SimpleZip.new("mine.zip");

# Add a file to the zip archive
$obj.add("somefile.txt".IO);

# Add a Blob/String
$obj.add("payload data here", :name<data1>);

$obj.close();
```


## Description

Simple write-only interface to allow creation of Zip files.

Please note - this is module is a prototype. The interface will change.

## Support

Suggestions/patches are welcomed via github at

   https://github.com/pmqs/Archive-SimpleZip

## Licence

Please see the LICENCE file in the distribution

(C) Paul Marquess 2016-2019

