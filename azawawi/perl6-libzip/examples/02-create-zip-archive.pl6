#!/usr/bin/env perl6

use v6;

use lib 'lib';
use LibZip;

# Remove the old one (just in case)
my $zip-file-name = "test.zip";
$zip-file-name.IO.unlink;

# Create a new LibZip instance
my $archive = LibZip.new;

# Create a new zip file
$archive.open($zip-file-name);

# Add file to zip archive
$archive.add-file("README.md");

# Add file to zip archive
my $lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
sunt in culpa qui officia deserunt mollit anim id est laborum.";
my Blob $blob = $lorem.encode("UTF-8");
$archive.add-blob("lorem.txt", $blob);

# Close the zip archive
$archive.close;
