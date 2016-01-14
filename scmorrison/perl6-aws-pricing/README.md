AWS::Pricing [![Build Status](https://travis-ci.org/scmorrison/perl6-aws-pricing.svg?branch=master)](https://travis-ci.org/scmorrison/perl6-aws-pricing)
============

Description
===========

Return current offers from the AWS Price List API.

Modules and utilities
=====================

AWS::Pricing
--------------

```perl6
use AWS::Pricing;
my $awsp = AWS::Pricing.new(aws_region => 'us-east-1', api_version => 'v1.0');

# List all Service Offer indexes
say $awsp.list-offers();
	
# List current offers for specific service
say $awsp.get-service-offers("AmazonS3");
# See code for available service codes
```

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

* Cache offer files, these are large
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
