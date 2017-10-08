WebService::AWS::S3
=======
Client for Amazon Web Services' Simple Storage Service

[![Build Status](https://travis-ci.org/bduggan/aws-s3-perl6.svg)](https://travis-ci.org/bduggan/aws-s3-perl6)

Synopsis
--------
```p6
use WebService::AWS::S3;

my $secret-access-key = 'passw0rd';
my $access-key-id = 'password1';
my $region = 'us-east-1';

my \s3 = S3.new(:secret-access-key, :$access-key-id, :$:region);

s3.put:
   content => "Hello, world!!",
   url     => "s3://my.own.bucket/hello/world.txt";

say s3.get("s3://my.own.bucket/hello/world.txt");
```

Description
-----------
This module provide a client for Amazon's S3 web service.

If you encounter a feature of S3 you want that's not
implemented by this module (and there are many), please
consider sending a pull request.

Overview
--------
WebService::AWS::S3 implements commands like `get`, `put`, `list-buckets`, and `list-objects`.

WebService::AWS::S3::Resources implement resources like `S3::Bucket` and `S3::Object`.

Examples
--------
These all assume the environment variables AWS_SECRET_ACCESS_KEY
and AWS_ACCESS_KEY_ID have been set.

* Print the contents of the first object in the first bucket.

```p6
use WebService::AWS::S3;

my \s3 = S3.new(:region<us-east-1>);
my $bucket-list = s3.list-buckets;
my $bucket      = $bucket-list[0] // die 'no buckets';
my $object-list = s3.list-objects(:$bucket);
my $object      = $object-list[0] // die "no objects in { $bucket.name }";
my $content     = s3.get($object);
say $content;
```

* Get contents from a known S3 bucket and key.

```p6
use WebService::AWS::S3;

my \s3 = S3.new(:region<us-east-1>);
say s3.get("s3://my.own.bucket/hello/world.txt")
```

* Put text to an S3 location.

```p6
use WebService::AWS::S3;

my \s3 = S3.new(:region<us-east-1>);
my $content = "Hello, world!";
my $url     = "s3://my.own.bucket/hello/world.txt";
say s3.put(:$content, :$url);
```

TODO
----
A lot.

