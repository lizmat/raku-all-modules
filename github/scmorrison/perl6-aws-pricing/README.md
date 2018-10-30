AWS::Pricing [![Build Status](https://travis-ci.org/scmorrison/perl6-aws-pricing.svg?branch=master)](https://travis-ci.org/scmorrison/perl6-aws-pricing)
============

Description
===========

Return, and cache, current offers from the AWS Price List API.

Usage
=====

```bash
aws-pricing - Pull AWS Pricing data from the AWS Pricing API

USAGE

    aws-pricing services
    aws-pricing service-offers <service_code>;
    aws-pricing service-codes
    aws-pricing regions 
    aws-pricing version

COMMANDS

    services           Return Service Offer index
    service-offers     Return Service Offers for specific service code and/or region
    service-codes      List all valid service codes
    regions            List all valid regions
    version            Display aws-pricing version

OPTIONS

    service-offers specific

    --format           json|csv Default json
    --region           Filter AWS region to pull offer data
    --header           Display the CSV header. Disabled by default

FLAGS

    --refresh          Force cache_dir refresh
    --cache_path       Path to cache path service offer files (Default ~/.aws-pricing)
    --quiet            No output, cache only (services, service-offers)
```

CLI
===

## List services
```
# Return Service Offer Index
aws-pricing services

# Refresh local cache
aws-pricing --refresh services

# Refresh local cache, no output
aws-pricing --refresh --quiet services
```

## List service offers
```
# Default json format
aws-pricing service-offers AmazonEC2

# Output csv format
aws-pricing --format=csv service-offers AmazonEC2

# Output csv format with headers
aws-pricing --headers --format=csv service-offers AmazonEC2

# Refresh local cache
aws-pricing --refresh --format=csv service-offers AmazonEC2

# Refresh local cache, no output
aws-pricing --refresh --quiet --format=csv service-offers AmazonEC2
```

## List valid Service Codes
```
aws-pricing service-codes
```

## List valid Regions
```
aws-pricing regions
```

## Print aws-pricing version
```
aws-pricing version
```

Modules and utilities
=====================

AWS::Pricing
--------------

```perl6
use AWS::Pricing;

my $config = AWS::Pricing::config(
    refresh    => True,
    cache_path => '~/.aws-pricing'  # Default path
);

# Service Offer Index JSON
AWS::Pricing::services;
	
# Service Offer Indexes with custom config
AWS::Pricing::services config => $config;

# Service Codes List
AWS::Pricing::service-codes;

# Regions List
AWS::Pricing::regions;

# Service Offers: All regions
AWS::Pricing::service-offers(service_code => 'AmazonEC2');

# Service Offers: Single region
AWS::Pricing::service-offers(
    service_code => 'AmazonEC2',
    region       => 'us-west-1'
);

# Service Offers: Single region, config, csv, region
AWS::Pricing::service-offers(
    config          => $config,
    service_code    => 'AmazonS3',
    format          => 'csv',
    region          => 'eu-west-1',
    display_header  => True
);
```

### Valid service codes:

* AmazonS3
* AmazonGlacier
* AmazonSES
* AmazonRDS
* AmazonSimpleDB
* AmazonDynamoDB
* AmazonEC2
* AmazonRoute53
* AmazonRedshift
* AmazonElastiCache
* AmazonCloudFront
* awskms
* AmazonVPC

### Valid regions

* us-east-1
* us-east-2
* us-west-1
* us-west-2
* eu-west-1
* ap-southeast-1
* ap-southeast-2
* ap-northeast-1
* ap-northeast-2
* sa-east-1
* eu-central-1
* us-gov-west-1
* ap-south-1
* ca-central-1
* eu-west-2

Installation
============

Install directly with zef:

```
zef install AWS::Pricing
```

Testing
=======

To run tests:

```
$ prove -e "perl6 -Ilib"
```

Todo
====

* ~~Cache offer files, these are large~~
* Search offers (must cache first)
* Tests

See also
========

* http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html

Authors
=======

  * Sam Morrison

Copyright and license
=====================

Copyright 2015 Sam Morrison

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
