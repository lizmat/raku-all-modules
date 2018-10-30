use v6;
use HTTP::Tinyish;

unit module AWS::Pricing:ver<0.2.3>:auth<github:scmorrison>;

our sub service-codes(
    --> List
) {
    "AmazonCloudFront",
    "AmazonDynamoDB",
    "AmazonEC2",
    "AmazonElastiCache",
    "AmazonGlacier",
    "AmazonRDS",
    "AmazonRedshift",
    "AmazonRoute53",
    "AmazonSES",
    "AmazonSimpleDB",
    "AmazonS3",
    "AmazonVPC",
    "awskms"
}

sub valid-service($code) {
   so service-codes() ~~ /^ $code $/;
}

our sub regions(
    --> List
) {
  	"ap-northeast-1",
  	"ap-northeast-2",
  	"ap-south-1",
  	"ap-southeast-1",
  	"ap-southeast-2",
  	"ca-central-1",
  	"eu-central-1",
  	"eu-west-1",
  	"eu-west-2",
  	"sa-east-1",
    "us-east-1",
  	"us-east-2",
  	"us-gov-west-1",
  	"us-west-1",
  	"us-west-2"
}

sub valid-region($region) {
   so regions() ~~ /^ $region $/;
}

sub path-exists(
    Str $path,
    Str $type
    --> Bool
) {
    return $path.IO ~~ :f when $type ~~ 'f';
    return $path.IO ~~ :d when $type ~~ 'd';
}

our sub strip-header-csv($data) {
		return S:x(5):g/\V+\v// given $data;
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
    Str  :$region where { $region ~~ ''|valid-region($region) } = '',
    Bool :$display_header = False
    --> Str
) {

    # Get Current Offers for specific Service
    my $cache_path = ["{$config<cache_path>}/service-offers", $service_code, $region]
                     .grep(/\w+/).join('-') ~ ".$format";

    # Use cached service offers if available
    if !$config<refresh> and path-exists($cache_path, 'f') {
        return $format ~~ 'csv' && !$display_header
            ?? strip-header-csv load-from-cache($cache_path)
            !! load-from-cache $cache_path;
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
    write-to-cache($cache_path, $data);

    return $format ~~ 'csv'
        && !$display_header
        ?? strip-header-csv $data !! $data;
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
