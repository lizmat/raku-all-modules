use v6.c;
use Test;

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

{
    use IP::Random;

    my $SIZE = 1_000;

    subtest 'Has Dupes', {
        my @excludes = (
            '0.0.0.0/2',
            '64.0.1.0/24',
            '64.0.2.0/23',
            '64.0.4.0/22',
            '64.0.8.0/21',
            '64.0.16.0/20',
            '64.0.32.0/19',
            '64.0.64.0/18',
            '64.0.128.0/17',
            '64.1.0.0/16',
            '64.2.0.0/15',
            '64.4.0.0/14',
            '64.8.0.0/13',
            '64.16.0.0/12',
            '64.32.0.0/11',
            '64.64.0.0/10',
            '64.128.0.0/9',
            '65.0.0.0/8',
            '66.0.0.0/7',
            '68.0.0.0/6',
            '72.0.0.0/5',
            '80.0.0.0/4',
            '96.0.0.0/3',
            '128.0.0.0/1'
        );
        my @out = IP::Random::random_ipv4(exclude => @excludes, count => $SIZE, allow-dupes => True );
        isnt @out.sort.repeated.elems, 0, 'There are duplicates (when there should be)';
        is @out.elems, $SIZE, "There are $SIZE elements";

        @out = IP::Random::random_ipv4(exclude => @excludes, count => $SIZE, allow-dupes => False );
        is @out.sort.repeated.elems, 0, 'There are not duplicates (when there shouldn\'t be)';
        is @out.elems, 256, "There are 256 elements";


        @out = IP::Random::random_ipv4(exclude => @excludes, count => 255, allow-dupes => False );
        is @out.sort.repeated.elems, 0, 'There are not duplicates (when there shouldn\'t be) x2';
        is @out.elems, 255, "There are 255 elements";

        done-testing;
    };
}

done-testing;

