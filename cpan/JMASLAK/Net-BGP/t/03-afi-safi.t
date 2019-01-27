use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::AFI  :ALL;
use Net::BGP::SAFI :ALL;

subtest 'afi' => {
    is afi-code('IP'),    1,       "IP correct¹";
    is afi-name(1),       'IP',    "IP correct²";

    is afi-code('15000'), 15000,   "15000 correct¹";
    is afi-name(15000),   '15000', "15000 correct²";

    dies-ok { afi-code('foobar') }, "Properly dies on unknown name";

    done-testing;
}

subtest 'safi' => {
    is safi-code('unicast'), 1,         "Unicast correct¹";
    is safi-name(1),         'unicast', "Unicast correct²";

    is safi-code('77'),      77,        "77 correct¹";
    is safi-name(77),        '77',      "77 correct²";

    dies-ok { safi-code('foobar') }, "Properly dies on unknown name";

    done-testing;
}

done-testing;

