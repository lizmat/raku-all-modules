AWS::Pricing [![Build Status](https://travis-ci.org/scmorrison/perl6-aws-pricing.svg?branch=master)](https://travis-ci.org/scmorrison/perl6-aws-pricing)
============

Description
===========

Return current offers from the AWS Price List API.

Usage
=====

```bash
Usage:

  aws-pricing list services
  aws-pricing [--format=json|csv] service offers <service_code>;

Optional arguments:
  
  --refresh    - Force cache_dir refresh
  --cache_dir  - Path to cache_dir service offer files (Default ~/.aws-pricing)
  --region     - AWS region to pull offer data (Default us-east-1)
```

Modules and utilities
=====================

AWS::Pricing
--------------

```perl6
use AWS::Pricing;

# List all Service Offer indexes
say AWS::Pricing::list-offers();
	
# List current offers for specific service. Valid formats are json or csv.
say AWS::Pricing::service-offers(service_code => 'AmazonS3', format => 'json');
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


Installation
============

Install directly with "panda":

    # From the source directory
   
		panda install .

		# Or with helper script

    ./scripts/install.sh


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
