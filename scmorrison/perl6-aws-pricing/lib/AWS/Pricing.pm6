use v6;
use HTTP::Tinyish;

unit module AWS::Pricing:ver<0.2.1>:auth<github:scmorrison>;

our sub service-codes(
    --> List
) {
    "AmazonS3",
    "AmazonGlacier",
    "AmazonSES",
    "AmazonRDS",
    "AmazonSimpleDB",
    "AmazonDynamoDB",
    "AmazonEC2",
    "AmazonRoute53",
    "AmazonRedshift",
    "AmazonElastiCache",
    "AmazonCloudFront",
    "awskms",
    "AmazonVPC"
}

sub valid-service($code) {
   so service-codes() ~~ /^ $code $/;
}

our sub regions(
    --> List
) {
    "us-east-1",
  	"us-east-2",
  	"us-west-1",
  	"us-west-2",
  	"eu-west-1",
  	"ap-southeast-1",
  	"ap-southeast-2",
  	"ap-northeast-1",
  	"ap-northeast-2",
  	"sa-east-1",
  	"eu-central-1",
  	"us-gov-west-1",
  	"ap-south-1",
  	"ca-central-1",
  	"eu-west-2"
}

sub valid-region($region) {
   so regions() ~~ /^ $region $/;
}

sub path-exists(
    Str $path,
    Str $type
    --> Bool
) {
    if $type ~~ 'f' { return $path.IO ~~ :f }
    if $type ~~ 'd' { return $path.IO ~~ :d }
}

sub load-from-cache(
    Str $cache_file
    --> Str
) {
    return slurp $cache_file;
}

sub write-to-cache(
    Str $cache_file,
    Str $data
    --> Bool
) {
    if !path-exists(config<cache_path>, 'd') {
        mkdir config<cache_path>.subst('~', $*HOME);
    }
    return spurt $cache_file, $data;
}

sub request(
    Str $url,
    Str $method='GET'
    --> Str
) {

    my $http = HTTP::Tinyish.new(agent => "AWS::Pricing/"~$?PACKAGE.^ver);
    my %res;
    if $method ~~ 'GET' {
        %res = $http.get($url); 
    } elsif $method ~~ 'PUT' {
        %res = $http.put($url); 
    }

    if (!%res<success>) {
        my %error = error => %res<reason>;
    }

    return %res<content>;
}

our sub services(
    Hash :$config = config()
    --> Str
) {
    my $cache = "{$config<cache_path>}/offers.json";

    # Use cached data if available
    if !$config<refresh> and path-exists($cache, 'f') {
      return load-from-cache $cache;
    }

    # No cache, or forced refresh
    # Get latest data from API

    # Reqest all Services available and their Current Offer URLs
    my $url = "https://pricing.us-east-1.amazonaws.com/offers/{$config<api_version>}/aws/index.json";
    my $data = request($url, 'GET');
    
    # Cache and return latest data from API
    return $data if write-to-cache($cache, $data);
}

our sub service-offers(
    Hash :$config = config(),
    Str  :$service_code!,
    Str  :$format where { $format ~~ 'json'|'csv' } = 'json',
    Str  :$region where { $region ~~ ''|valid-region($region) } = ''
    --> Str
) {

    # Get Current Offers for specific Service
    my $cache_path = ["{$config<cache_path>}/service-offers", $service_code, $region]
                     .grep(/\w+/).join('-') ~ ".$format";

    # Use cached service offers if available
    if !$config<refresh> and path-exists($cache_path, 'f') {
      return load-from-cache $cache_path;
    }

    # No cache, or forced refresh
    # Get latest data from API

    # Confirm $offer_code is valid
    if (!valid-service($service_code)) {
        return "Invalid Service Code. Please use one of the following:\n\n" ~ service-codes().join("\n");
    }

    my $url = ["https://pricing.us-east-1.amazonaws.com/offers", $config<api_version>, "aws/$service_code/current", $region]
              .grep(/\w+/).join('/') ~ "/index.$format";

    my $data = request($url, 'GET');

    # Cache and return latest data from API
    return $data if write-to-cache($cache_path, $data);
}

our sub config(
    :$api_version = 'v1.0',
    :$cache_path  = "$*HOME/.aws-pricing",
    :$refresh     = False
    --> Hash
  ) {
    %(api_version => $api_version,
      cache_path  => IO::Path.new($cache_path.subst('~', $*HOME)).Str,
      refresh     => $refresh);
};

# vim: ft=perl6
