#!/usr/bin/env perl6

use lib 'lib';
use Test;
use WebService::AWS::S3::Resources;

plan 5;

my $owner = S3::Owner.new;
isa-ok $owner, S3::Owner;

my $object-list = S3::ObjectList.new;
isa-ok $object-list, S3::ObjectList;
my $object = S3::Object.new;
isa-ok $object, S3::Object;

my $bucket-list = S3::BucketList.new;
isa-ok $bucket-list, S3::BucketList;
my $bucket = S3::Bucket.new;
isa-ok $bucket, S3::Bucket;
