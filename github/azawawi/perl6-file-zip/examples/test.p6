#!/usr/bin/env perl6

use v6;

use lib 'lib';
use File::Zip;

my $zip-file = File::Zip.new( file-name => 'examples/webdriver.xpi' );

say $_.perl for $zip-file.files;

$zip-file.unzip( directory => 'output' );

LEAVE {
  $zip-file.close if $zip-file.defined;
}

