#!/usr/bin/env perl6

use lib 'lib';
use WebService::AWS::S3;
use HTTP::Request;
use URI;
use Test;
plan 4;

class Mock {
    has $.data;
    method request(HTTP::Request $req) {
        my $file = $*PROGRAM.parent;
        $file .= child($_)
            for (
            << mock data "{$req.uri.host}" >>,
            $req.uri.path.split("/"),
            'response.xml'
            ).flat;
        $file.e or die "no mock data $file";
        return Mock.new(data => $file.slurp);
    }
    method code {
       return 200;
    }
    method content() {
        return $.data;
    }
}

my $mock = Mock.new;

my $s3 = S3.new(:secret-access-key<none>, :access-key-id<none>, :ua($mock), :region<none>);
my $buckets = $s3.list-buckets;
is $buckets.owner.display-name, 'fred', 'owner';
is $buckets.owner.id, 'deadbeaf', 'deadbeaf';
my $bucket = $buckets[0];
isa-ok $bucket, S3::Bucket;
my $objects = $s3.list-objects(:$bucket);
is $objects[0].key, 'fred/test-1.txt', 'object key';
