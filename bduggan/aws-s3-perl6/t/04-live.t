#!/usr/bin/env perl6

use lib 'lib';
use WebService::AWS::S3;
use Test;
plan 14;

unless %*ENV<AWS_TEST_BUCKET> && %*ENV<AWS_TEST_PREFIX> {
  note "set AWS_TEST_BUCKET and AWS_TEST_PREFIX to run live tests";
  skip-rest "set AWS_TEST_BUCKET to enable live tests";
  exit
}

my $test-bucket = %*ENV<AWS_TEST_BUCKET>;
my $prefix = %*ENV<AWS_TEST_PREFIX>;

my $s3 = S3.new(:region<us-east-1>);
my $result = $s3.list-buckets;
isa-ok $result[0], S3::Bucket, "Got an s3 bucket";
my $count = 0;
for $result.buckets -> $b { $count++; }
is $count, $result.elems, "found $count buckets";
diag .name for $result.flat;

my $bucket  = $result{$test-bucket};
ok $bucket, "Found $test-bucket";

my $objects = $s3.list-objects(:$bucket, :$prefix);
isa-ok $objects, S3::ObjectList;

my $object  = $objects[0];
isa-ok $object, S3::Object;
with $object {
    my $key = $object.key;
    my $clone = $objects{$key};
    isa-ok $clone, 'S3::Object';
    is $key, $clone.key, "associative access (by key)";
    ok $object.last-modified ~~ DateTime, "got a DateTime for last-modified";
    ok $object.owner.display-name ~~ Str, "got a Str for owner.display-name";
    like $object.url, / ^ 's3://' /, $object.url;
    like $object.etag, / \w+ /, $object.etag;

    my $str = $s3.get($object);
    ok $str, 'got some content';
} else {
   skip 'no object', 7;
}

my $content = "hello, s3 + { now.Rat } ";
my $url = "s3://$test-bucket/{ chop $prefix }/new-file.txt";
ok $s3.put(:$content,:$url), "put plaintext";
sleep 1;
my $got = $s3.get($url);
is $content, $got, "roundtrip";


