use v6;

=begin pod

=head1 NAME

WebService::AWS::Auth::V4 - A Perl6 implementation of AWS v4 authentication methods.

=head1 DESCRIPTION

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

=head1 SYNOPSIS

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

=head1 AUTHOR

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org)

=head1 LICENSE

This module is licensed under the BSD license, see:

https://b7j0c.org/stuff/license.txt

=end pod

unit module WebService::AWS::Auth::V4:auth<bradclawsie>:ver<0.0.3>;

use Digest::SHA;
use Digest::HMAC;
use URI;
use URI::Escape;

# perhaps right way to do this is to just have a constructor that takes a URI, headers, and body

class X::WebService::AWS::Auth::V4::ParseError is Exception is export {
    has $.input;
    has $.err;
    method message() { "With $.input, parse error: $.err" }
}

class X::WebService::AWS::Auth::V4::MethodError is Exception is export {
    has $.input;
    method message() { "With $.input, missing http method. Only GET POST HEAD are supported"; }
}

# These are the methods that can be used with AWS services.
our constant $Methods = set < GET POST HEAD >; 

# HMAC algorithm.
our constant $HMAC_name      = 'AWS4-HMAC-SHA256';

# Signing version.
our constant $Auth_version   = 'AWS4';

# Host header normalized key.
our constant $Host_key       = 'host';

# X-Amz-Date header normalized key.
our constant $X_Amz_Date_key = 'x-amz-date';

# Termination string required in credential scope.
our constant $AWS4_request = 'aws4_request';

class WebService::AWS::Auth::V4 {

    has Str $.method is required;
    has Str @.headers is required;
    has Str $.body is required;
    has Str $.region is required;
    has Str $.service is required;
    has Str $.secret is required;
    has Str $.access_key is required;
    has URI $!uri;
    has Str %!header_map;
    has DateTime $!amz_date;
    
    submethod BUILD(Str:D :$method, :$body, :$uri, :$region, :$service, :$secret, :$access_key, :@headers) { 

        # Make sure the method passed is allowed
        unless $method (elem) $Methods {
            X::WebService::AWS::Auth::V4::MethodError(input => $method).throw;
        }
        $!method := $method;

        @!headers := @headers;
        $!body := $body;
        $!secret := $secret;
        $!access_key := $access_key;
        $!region = $region.lc;
        $!service = $service.lc;
        
        # Map the lowercased and trimmed header names to trimmed header values. Will throw
        # an exception if there is an error, let caller catch it.
        %!header_map = map-headers(@headers);

        # Now create a URI obj from the URI string and make sure that the method and host are set.
        $!uri = URI.new(:$uri);
        unless $!uri.scheme ne '' && $!uri.host ne '' {
            X::WebService::AWS::Auth::V4::ParseError.new(input => :$uri,err => 'cannot parse uri').throw;
        }

        # If the $X_Amz_Date_key is not found, map_headers would have thrown an exception.
        # parse_amz_date will also throw an exception of the header value cannot be parsed,
        # let caller catch it.
        $!amz_date = parse-amz-date(%!header_map{$X_Amz_Date_key});
    }

    # Transform the Str array of headers into a hash where lc keys are mapped to normalized vals.
    my sub map-headers(Str:D @headers --> Hash:D) {
        my %header_map = ();
        for @headers -> $header {
            if $header ~~ /^(\S+)\:(.*)$/ {
                my ($k,$v) = ($0,$1);
                $v = $v.trim;
                if $v !~~ / '"' / {
                    $v ~~ s:g/\s+/ /;
                } 
                %header_map{$k.lc.trim} = $v;
            } else {
                X::WebService::AWS::Auth::V4::ParseError.new(input => $header,err => 'cannot parse header').throw;
            }
        }
        for $Host_key, $X_Amz_Date_key -> $k {
            unless %header_map{$k}:exists {
                X::WebService::AWS::Auth::V4::ParseError.new(input => @headers.join("\n"),err => $k ~ ' header required').throw;
            }
        }
        %header_map;
    }

    # Get the SHA256 for a given string.
    our sub sha256-base16(Str:D $s --> Str:D) is export {
        my $sha256 = sha256 $s.encode: 'ascii';
        [~] $sha256.list».fmt: "%02x";
    }

    # Old name for sha256-base16; support old api.
    our sub sha256_base16(Str:D $s --> Str:D) is export {
        sha256-base16 $s;
    }
    
    # Use this as a 'formatter' method for a DateTime object to get the X-Amz-Date format.
    our sub amz-date-formatter(DateTime:D $dt --> Str:D) is export {
        sprintf "%04d%02d%02dT%02d%02d%02dZ",
        $dt.utc.year,
        $dt.utc.month,
        $dt.utc.day,
        $dt.utc.hour,
        $dt.utc.minute,
        $dt.utc.second; 
    }

    # Old name for amz_date_formatter; support old api.
    our sub amz_date_formatter(DateTime:D $dt --> Str:D) is export {
        amz-date-formatter $dt;
    }
    
    # Use this to get the yyyymmdd for a DateTime for use in various signing contexts.
    our sub amz-date-yyyymmdd(DateTime:D $dt --> Str:D) is export {
        sprintf "%04d%02d%02d", $dt.utc.year, $dt.utc.month, $dt.utc.day;    
    }

    # Old name for amz_date_yyyymmdd; support old api.
    our sub amz_date_yyyymmdd(DateTime:D $dt --> Str:D) is export {
        return amz-date-yyyymmdd $dt;
    }

    # Parse AWS date format.
    our sub parse-amz-date(Str:D $s --> DateTime:D) is export {
        if $s ~~ / ^(\d ** 4)(\d ** 2)(\d ** 2)T(\d ** 2)(\d ** 2)(\d ** 2)Z$ / {
            return DateTime.new(year=>$0,
                                month=>$1,
                                day=>$2,
                                hour=>$3,
                                minute=>$4,
                                second=>$5,
                                formatter=>&amz-date-formatter);
        } else {
            X::WebService::AWS::Auth::V4::ParseError.new(input => $s,err => 'cannot parse X-Amz-Date').throw;
        }
    }

    # Old name for parse_amz_date; support old api.
    our sub parse_amz_date(Str:D $s --> DateTime:D) is export {
        parse-amz-date $s;
    }

    # STEP 1 CANONICAL REQUEST
    
    method canonical-uri(--> Str:D) is export {
        my Str $path = $!uri.path;
        return '/' if $path.chars == 0 || $path eq '/';
        $path.split("/").map({uri-escape($_)}).join("/");
    }

    # Old name for canonical-uri; support old api.
    method canonical_uri(--> Str:D) is export {
        self.canonical-uri;
    }
    
    method canonical-query(--> Str:D) is export {
        my Str $query = $!uri.query;
        return '' if $query.chars == 0;
        my Str @pairs = $query.split('&');
        my Str @escaped_pairs = ();
        for @pairs -> $pair {
            if $pair ~~ /^(\S+)\=(\S*)$/ {
                my ($k,$v) = ($0,$1);
                push(@escaped_pairs,uri-escape($k) ~ '=' ~ uri-escape($v));
            } else {
                X::WebService::AWS::Auth::V4::ParseError.new(input => $pair,err => 'cannot parse query key=value').throw;
            }
        }
        @escaped_pairs.sort().join('&');
    }

    # Old name for canonical-query; support old api.
    method canonical_query(--> Str:D) is export {
        self.canonical-query;
    }
    
    method canonical-headers(--> Str:D) is export {
        %!header_map.keys.sort.map( -> $k { $k ~ ':' ~ %!header_map{$k}} ).join("\n") ~ "\n";
    }

    # Old name for canonical-headers; support old api.
    method canonical_headers(--> Str:D) is export {
        self.canonical-headers;
    }
    
    method signed-headers(--> Str:D) is export {
        %!header_map.keys.sort.join(';');
    }

    # Old name for signed-headers; support old api.
    method signed_headers(--> Str:D) is export {
        self.signed-headers;
    }
    
    method canonical-request(--> Str:D) is export {
        ($!method,
         self.canonical-uri(),
         self.canonical-query(),
         self.canonical-headers(),
         self.signed-headers(),
         sha256-base16($!body)).join("\n");
    }

    # Old name for canonical-request; support old api.
    method canonical_request(--> Str:D) is export {
        self.canonical-request;
    }
    
    # STEP 2 STRING TO SIGN

    method string-to-sign(--> Str:D) is export {
        ($HMAC_name,
         $!amz_date.Str,
         (amz-date-yyyymmdd($!amz_date),
         $!region,
         $!service,
         $AWS4_request).join('/'),
         sha256-base16(self.canonical-request())).join("\n");
    }

    # Old name for string-to-sign; support old api.
    method string_to_sign(--> Str:D) is export {
        self.string-to-sign;
    }

    # STEP 3 CALCULATE THE AWS SIGNATURE

    method signature(--> Str:D) is export {
        my $kdate    = hmac($Auth_version ~ $!secret,amz-date-yyyymmdd($!amz_date),&sha256);
        my $kregion  = hmac($kdate,$!region,&sha256);
        my $kservice = hmac($kregion,$!service,&sha256);
        my $ksigning = hmac($kservice,$AWS4_request,&sha256);
        hmac-hex($ksigning,self.string-to-sign(),&sha256);
    }

    # STEP 4 GENERATE THE SIGNING HEADER

    method signing-header(--> Str:D) is export {
        my $credential = $!access_key ~ '/' ~ amz-date-yyyymmdd($!amz_date) ~ '/' ~ $!region ~ '/' ~
        $!service ~ '/' ~ $AWS4_request;
        'Authorization: ' ~ $HMAC_name ~ ' Credential=' ~ $credential ~
        ', SignedHeaders=' ~ self.signed-headers() ~ ', Signature=' ~ self.signature();
    }

    # Old name for signing-header; support old api.
    method signing_header(--> Str:D) is export {
        self.signing-header;
    }
}

