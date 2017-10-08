#!/usr/bin/env perl6

use v6;
use Test;
use JSON::Fast;
use URI::Escape;
use Digest::SHA;
use HTTP::UserAgent;
use HTTP::Request::Common;
use WebService::AWS::S3::Resources;
use WebService::AWS::S3::Request;

class S3::URL {
    has Str $.bucket;
    has Str $.path;
    method parse($str) {
        $str ~~ /^ 's3://' $<bucket>=(<-[/]>+) $<path>=(.*) $/ or return;
        return S3::URL.new(:bucket( ~$<bucket> ), :path( ~$<path> ) );
    }
}

class S3 {
  has $.aws-host = 's3.amazonaws.com';
  has $.region = 'us-east-1';
  has $.secret-access-key = %*ENV<AWS_SECRET_ACCESS_KEY> || die "Please set AWS_SECRET_ACCESS_KEY";
  has $.access-key-id = %*ENV<AWS_ACCESS_KEY_ID> || die "Please set AWS_ACCESS_KEY_ID";
  has $.ua = HTTP::UserAgent.new;
  has $!req;
  has $!res;

  method signed-headers(:$host!, :$path!, Str:D :$body="", :$query-string, :$method="GET" --> Hash) {
    my $region     = 'us-east-1';
    my $sha        = sha256($body).map({.fmt('%02x')}).join;
    my $now = DateTime.now;
    my %headers =
      :Host( $host ),
      :X-Amz-Date( timestamp($now) ),
      :X-AMZ-Content-SHA256( $sha ),
      ;
    my $req = S3::Request.new(
       :$.secret-access-key,
       :$.region,
       :$.access-key-id,
       :$path
       :$query-string,
       :$body,
       :date($now),
       :verb($method),
       :$host,
       :%headers
     );
    my $auth = $req.authorization;
    return %headers.append("Authorization" => $auth);
  }

  method print-error {
    my $error = S3::Error.from-xml($!res.content);
    say "Error: { $!res.status-line } { $error.code }";
    if $error.code eq 'SignatureDoesNotMatch' {
        say "mismatch\n";
        say $error.canonical-request-bytes.split(' ').map({chr("0x$_")}).join;
        say "--";
        say $!req.canonical-request;
    } else {
        say $!res.content;
    }
  }

  method do-request(:$subdomain,:$path is copy ='',:$query) {
    my $host = (|($subdomain xx so $subdomain), $.aws-host).join('.');
    $path = "/$path" unless $path ~~ / ^ '/' /;
    my $uri = 'https://' ~ $host ~ $path;
    my $query-string = "";
    if $query {
        $query-string = join '&', map {"{.key}={uri-escape(.value.Str)}"}, $query.pairs.sort;
        $uri ~= '?' ~ $query-string;
    }
    $!req = GET $uri,|self.signed-headers(:$host,:$path,:$query-string);
    $!res = $.ua.request($!req);
    if $!res.code != 200 {
        self.print-error;
        return;
    }
    return $!res;
  }

  method do-put-request(:$subdomain, :$path is copy='', Str:D :$content="") {
    my $host = (|($subdomain xx so $subdomain), $.aws-host).join('.');
    $path = "/$path" unless $path ~~ / ^ '/' /;
    my $uri = 'https://' ~ $host ~ $path;
    $!req = PUT $uri,
                |self.signed-headers(:$host,:$path,:body($content),:method<PUT>),
              content => $content;
    $!res = $.ua.request($!req);
    if $!res.code != 200 {
        self.print-error;
        return;
    }
    return $!res;
  }

  method list-buckets {
    my $res = self.do-request(:path('')) or return;
    return S3::BucketListResult.from-xml($res.content);
  }

  method list-objects(S3::Bucket :$bucket, Str :$prefix, Int :$max-keys=20, Str :$delimiter='/') {
    my $query = { };
    $query<prefix> = $prefix if $prefix;
    $query<max-keys> = $max-keys if $max-keys;
    $query<delimiter> = $delimiter if $delimiter;
    my $res = self.do-request(:subdomain($bucket.name),:path('/'),:$query) or return;
    my $objects = S3::ObjectList.from-xml($res.content);
    for $objects.objects -> $object {
        $object.bucket = $bucket;
    }
    return $objects;
  }

  multi method get(S3::Object:D $object) {
    my $res = self.do-request(:path($object.key), :subdomain($object.bucket.name));
    # say $res.header.fields.map({ .name => .values}).perl;
    return $res.content;
  }

  multi method get(Str $url) {
    my $s3-url = S3::URL.parse($url) or die "can't parse $url";
    return self.get:
        S3::Object.new:
            key => $s3-url.path,
            bucket => S3::Bucket.new: name => $s3-url.bucket
  }

  method put(Str:D :$content="", :$url) {
      my $s3-url = S3::URL.parse($url);
      my $res = self.do-put-request(:path($s3-url.path), :subdomain($s3-url.bucket), :$content);
      return $res.code == 200;
  }

}

