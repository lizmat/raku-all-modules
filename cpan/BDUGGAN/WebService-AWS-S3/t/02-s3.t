#!/usr/bin/env perl6

use lib 'lib';
use WebService::AWS::S3;
use Test;
plan 3;

my @existing = %*ENV<AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID>:delete;
dies-ok { S3.new }, 'no access key';
my $s3 = S3.new(secret-access-key => 'test', access-key-id => 'test', region => 'nowhere');

isa-ok $s3, S3;
can-ok $s3, 'list-buckets';


