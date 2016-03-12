#!/usr/bin/env perl6

use v6;

use lib 'lib';
use LibZip;

# Remove the old one (just in case)
my $zip-file-name = "test.zip";
$zip-file-name.IO.unlink;

my $archive = LibZip.new;

# Create a new zip file
$archive.open($zip-file-name);

# Add file to zip archive
#$archive.add-file("README.md");

# Add file to zip archive
#$archive.add-buffer(@buffer);

=begin ignore


my $file-data-source = zip_source_file($archive, $filename, 0, -1);
die "Failed!" unless $file-data-source;

# Prepare a zip data source from memory buffer
my @data := CArray[int8].new;
@data[0]  = 'A'.ord;
@data[1]  = 'B'.ord;
@data[2]  = 'C'.ord;
my $memory-data-source = zip_source_buffer($archive, @data, @data.elems, 0);
unless $memory-data-source {
  my $error-code        = CArray[int32].new;
  my $system-error-code = CArray[int32].new;
  zip_error_get($archive, $error-code, $system-error-code);
  die "Failed with the following error code: $($error-code[0]) and system error code: $($system-error-code[0])";
}

# Add file data source to zip archive
my $result = zip_add($archive, $filename.IO.basename, $file-data-source);
die "Failed" if $result == -1;

# Add memory data source to zip archive
$result = zip_add($archive, "Hello.txt", $memory-data-source);
die "Failed" if $result == -1;

# Close the zip archive
$result = zip_close($archive);
die "Failed" if $result != ZIP_ER_OK;
=end ignore
