use v6.c;
use Test;

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

{
    use IP::Random;

    subtest 'Constants', {
        ok defined(IP::Random::{'named_exclude'}),         'named_exclude';

        done-testing;
    };

    subtest 'Methods', {
        ok defined(IP::Random::{'&default_ipv4_exclude'}), 'default_ipv4_exclude';
        ok defined(IP::Random::{'&exclude_ipv4_list'}),    'exclude_ipv4_list';

        done-testing;
    };
}

done-testing;

