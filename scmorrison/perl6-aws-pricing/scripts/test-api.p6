#!/usr/bin/env perl6

use v6;

use JSON::Pretty;
use AWS::Pricing;

my $awsp = AWS::Pricing.new(aws_region => 'us-east-1', api_version => 'v1.0');
#say $awsp.list-offers;
say $awsp.get-service-offers("AmazonS3");
