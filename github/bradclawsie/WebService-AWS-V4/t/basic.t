use v6;
use Test;
use URI;
use WebService::AWS::Auth::V4;

plan 26;

my Str @headers = "Host:iam.amazonaws.com",
   "Content-Type:application/x-www-form-urlencoded; charset=utf-8",
   "My-header1:    a   b   c ",
   "X-Amz-Date:20150830T123600Z",
   "My-Header2:    \"a     b   c\"";

my Str @missing_host_header = @headers[1 .. @headers.end];

my Str @malformed_headers = ( "Host iam.amazonaws.com" );

my constant $canonical_headers = "content-type:application/x-www-form-urlencoded; charset=utf-8\nhost:iam.amazonaws.com\nmy-header1:a b c\nmy-header2:\"a     b   c\"\nx-amz-date:20150830T123600Z\n";

my $signed_headers = "content-type;host;my-header1;my-header2;x-amz-date";

my constant $service = 'iam';
my constant $region = 'us-east-1';
my constant $secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY';
my constant $access_key = 'AKIDEXAMPLE';
my constant $uri_str = 'https://iam.amazonaws.com/';
my constant $get = 'GET';
my constant $aws_sample_uri = 'https://iam.amazonaws.com/?Action=ListUsers&Version=2010-05-08';
my Str @aws_sample_headers = "Host:iam.amazonaws.com",
   "Content-Type:application/x-www-form-urlencoded; charset=utf-8",
   "X-Amz-Date:20150830T123600Z";

lives-ok {
    my $example_date_str = '20150830T123600Z';
    my $dt_s = DateTime.new(year=>2015,month=>8,day=>30,hour=>12,minute=>36,second=>0,timezone=>0,formatter=>&WebService::AWS::Auth::V4::amz_date_formatter);
    is $dt_s.Str, $example_date_str, 'match aws date example';
    my $dt_o = WebService::AWS::Auth::V4::parse-amz-date($dt_s.Str);
    is ($dt_s == $dt_o), True, 'date objects round trip';
    is ($dt_s.Str eq $dt_o.Str), True, 'date strings round trip';
}, 'date formatting';

lives-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => $uri_str, headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'correctly initialize well-formed obj';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => '', body => '', uri => $uri_str, headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception when trying to initialize with missing method';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => 'PUT', body => '', uri => $uri_str, headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception when trying to initialize with bad method';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => '', headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception when trying to initialize with missing uri';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'htt', headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception when trying to initialize with malformed uri';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'https://iam.amazonaws.com/home/documents+and+settings?a/z=b&C=d', headers => @missing_host_header, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception on missing host header';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'https://iam.amazonaws.com/home/documents+and+settings?a/z=b&C=d', headers => @malformed_headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
}, 'caught exception on malformed headers';

lives-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => $uri_str, headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
    is $v4.canonical-uri(), '/', 'canonicalizes empty URI path';
    is $v4.canonical-query(), '', 'canonicalizes empty query';
}, 'correctly canonicalized empty';

lives-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'https://iam.amazonaws.com/home/documents+and+settings?a/z=b&C=d', headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
    is $v4.canonical-uri(), '/home/documents%2Band%2Bsettings', 'canonicalizes nonempty URI path';
    is $v4.canonical-query(), 'C=d&a%2Fz=b', 'canonicalizes nonempty query';
}, 'correctly canonicalized nonempty query';

dies-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'https://iam.amazonaws.com/home/documents+and+settings?ab&C=d', headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
    my $q = $v4.canonicalize-query();
}, 'caught exception on malformed key-value query pair';

lives-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => 'https://iam.amazonaws.com/home/documents+and+settings?a/z=b&C=d', headers => @headers, region => $region, service => $service, secret => $secret, access_key => $access_key);
    is $v4.canonical-headers(), $canonical_headers, 'match canonical headers';
    is $v4.signed-headers(), $signed_headers, 'match signed headers';
}, 'correctly canonicalized headers';

lives-ok {
    my $v4 = WebService::AWS::Auth::V4.new(method => $get, body => '', uri => $aws_sample_uri, headers => @aws_sample_headers, region => $region, service => $service, secret => $secret, access_key => $access_key);

    my $cr = $v4.canonical-request();
    my $cr_sha256 = WebService::AWS::Auth::V4::sha256-base16($cr);
    is WebService::AWS::Auth::V4::sha256_base16($cr), 'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59', 'match aws test signature for canonical request';

    is $v4.string_to_sign, "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/iam/aws4_request\nf536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59", 'string to sign';

    is $v4.signature, '5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7', 'signature';

    is $v4.signing-header(), 'Authorization: AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/iam/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7', 'authorization header';
    
}, 'correctly match canonical request test from aws';

done-testing;
