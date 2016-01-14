#!/usr/bin/env perl6

use v6;

use HTTP::Tinyish;

class X::AWS::Pricing is Exception {
    has $.status;
    has $.reason;

    method message() {
        "Error: '$.status $.reason'";
    }
}

class AWS::Pricing:ver<0.1.0>:auth<github:scmorrison> {

    has $.aws_region is rw = 'us-east-1';
    has $.api_version is rw = 'v1.0';
    has $.aws_pricing_api_uri;
    has @.offer_codes = ["AmazonS3",
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
                         "AmazonVPC"];

    method BUILD(:$!aws_region, :$!api_version) {

    }
    
    method request(Str $url, Str $method='GET') {

        my $http = HTTP::Tinyish.new(agent => "perl6-aws-pricing/0.1.0");
        my %res;
        if $method ~~ 'GET' {
            %res = $http.get($url); 
        } elsif $method ~~ 'PUT' {
            %res = $http.put($url); 
        }

        if (!%res<success>) {
            X::AWS::Pricing.new(reason => %res<reason>).throw;
        }

        return %res<content>;
    }

    method list-offers() {
        # List all Services available and their Current Offer URLs

        my $current_offers_url = "https://pricing." ~ $!aws_region ~ ".amazonaws.com/offers/" ~ $!api_version ~ "/aws/index.json";
        self.request($current_offers_url, 'GET');
    
    }

    method get-service-offers(Str $offer_code) {
        # Get Current Offers for specific Service

        # Confirm $offer_code is valid
        if (!@.offer_codes.first: $offer_code) {
            X::AWS::Pricing.new(reason => "Invalid Offer Code. Please use one of the following: \n" ~ @.offer_codes).throw;
        }

        my $offer_url = "https://pricing." ~ $!aws_region ~ ".amazonaws.com/offers/" ~ $!api_version ~ "/aws/" ~ $offer_code ~ "/current/index.json";
        self.request($offer_url, 'GET');
    }

}
