#!perl

use strict;
use JSON qw{decode_json encode_json};

my $build_id = $ENV{BUILD_BUILDID} || shift();

open JSON, "package.json" or die "can't open package.jspon to read: $!";
my $js = join "", <JSON>;
close JSON;


my $data = decode_json($js);
my $pack_version = $data->{version};

print "set version ...\n";
print "version (taken from package.json) - $pack_version ...\n";
print "build_id - $build_id ...\n";

print "update package.json file ...\n";

$pack_version=~s/\.(\d+)$/.$build_id/;
print "patched version - $pack_version ...\n";

$data->{version} = $pack_version;

open JSON, ">", "package.json" or die "can't open package.jspon to write: $!";
print JSON (encode_json($data));
close JSON;


