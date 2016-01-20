[![Build Status](https://travis-ci.org/bradclawsie/WebService-AWS-Auth-V4.png)](https://travis-ci.org/bradclawsie/WebService-AWS-V4)

# Description

AWS employs a set of signing processes in order to create authorized requests. This
library provides an implementation of the v4 signing requirements as described here:

http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html

This library conforms to a set of published conformance tests that AWS publishes
here:

http://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html

This library passes these tests. This is not a general purpose library
for using AWS services, although v4 signing is a requirement for any
toolkit that provides an AWS API, so this library may be useful
as a foundation for an AWS API.                                                                     

# Synopsis

The best synopsis comes from the unit test:

    use v6;
    use Test;
    use WebService::AWS::Auth::V4;

    my constant $service = 'iam';
    my constant $region = 'us-east-1';
    my constant $secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY';
    my constant $access_key = 'AKIDEXAMPLE';
    my constant $get = 'GET';
    my constant $aws_sample_uri = 'https://iam.amazonaws.com/?Action=ListUsers&Version=2010-05-08';
    my Str @aws_sample_headers = "Host:iam.amazonaws.com",
       "Content-Type:application/x-www-form-urlencoded; charset=utf-8",
       "X-Amz-Date:20150830T123600Z";
                                  
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => $aws_sample_uri, headers => @aws_sample_headers, region => $region, service => $service, secret => $secret, access_key => $access_key);

    my $cr = $v4.canonical_request();
    my $cr_sha256 = WebService::AWS::Auth::V4::sha256_base16($cr);
    is WebService::AWS::Auth::V4::sha256_base16($cr), 'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59', 'match aws test signature for canonical request';

    is $v4.string_to_sign, "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/iam/aws4_request\nf536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59", 'string to sign';

    is $v4.signature, '5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7', 'signature';

    is $v4.signing_header(), 'Authorization: AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/iam/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7', 'authorization header';

