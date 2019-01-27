use v6.c;
use Test;

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

use IP::Random;

dies-ok { IP::Random::random_ipv4(exclude => [ 'foo' ]) },        "Invalid exclude type";
dies-ok { IP::Random::random_ipv4(exclude => [ '256.0.0.0' ]) },  "Invalid IP address";
dies-ok { IP::Random::random_ipv4(exclude => [ '1.2.3.4/39' ]) }, "Invalid CIDR prefix length";
dies-ok { IP::Random::random_ipv4(exclude => [ '1.2.3.4/24' ]) }, "Invalid CIDR base address";

done-testing;

