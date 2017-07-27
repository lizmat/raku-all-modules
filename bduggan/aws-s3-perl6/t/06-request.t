use lib 'lib';
use WebService::AWS::S3::Request;

use Test;
plan 1;

my $req = S3::Request.new(
    access-key-id => 'key123',
    secret-access-key => 'secret456',
    region => 'us-east',
    host => 'bucket.name.s3.aws.com',
    verb => "GET",
    path => '/bduggan/file.txt',
    date => DateTime.new(:year(2000),:month(12),:day(12),:10hour,:9minute,:11seconds)
);
is $req.authorization, "AWS4-HMAC-SHA256 Credential=key123/20001212/us-east/s3/aws4_request,SignedHeaders=host;x-amz-date,Signature=68fae1ddd2a776c0bff8262c8901bfc96d76bc0c91886a6e197117f972ce239e", 'known auth header';

