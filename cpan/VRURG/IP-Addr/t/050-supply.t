#! /usr/bin/env perl6

use v6.c;

use Test;
use IP::Addr;

plan 2;

subtest "IPv4" => {
    plan 6;
    my $ip;
    my (@res, @exp);
    
    $ip = IP::Addr.new( "192.168.13.0/29" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };

    for 0..7 -> $oct {
        @exp.push: IP::Addr.new( "192.168.13.$oct/29" );
    }

    is-deeply @res.map( { ~$_ } ), @exp.map( { ~$_ } ), "CIDR sequence";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_.ip } ), "CIDR IP sequence";
    
    $ip = IP::Addr.new( "192.168.13.3/29" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };

    @exp = [];
    for 3..7 -> $oct {
        @exp.push: IP::Addr.new( "192.168.13.$oct/29" );
    }

    is-deeply @res.map( { ~$_ } ), @exp.map( { ~$_ } ), "CIDR sequence -- from mid-network";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_.ip } ), "CIDR IP sequence -- from mid-network";
    
    $ip = IP::Addr.new( "192.168.13.10-192.168.13.30" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };
 
    @exp = [];
    for 10..30 -> $oct {
        @exp.push: IP::Addr.new( "192.168.13.$oct" );
    }   

    is-deeply @res.map( { ~$_ } ), "192.168.13.10-192.168.13.30" xx 21, "range sequnce";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_ } ), "range IP sequnce";
}

subtest "IPv6" => {
    plan 6;
    my $ip;
    my (@res, @exp);
    
    $ip = IP::Addr.new( "2001::/125" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };

    for 0..7 -> $oct {
        @exp.push: IP::Addr.new( "2001::$oct/125" );
    }

    is-deeply @res.map( { ~$_ } ), @exp.map( { ~$_ } ), "CIDR sequence";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_.ip } ), "CIDR IP sequence";
    
    $ip = IP::Addr.new( "2001::2/125" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };

    @exp = [];
    for 2..7 -> $oct {
        @exp.push: IP::Addr.new( "2001::$oct/125" );
    }

    is-deeply @res.map( { ~$_ } ), @exp.map( { ~$_ } ), "CIDR sequence -- from mid-network";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_.ip } ), "CIDR IP sequence -- from mid-network";
    
    $ip = IP::Addr.new( "2001::a-2001::1e" );

    @res = gather {
        react {
            whenever $ip.Supply -> $iter {
                take $iter;
            }
        }
    };
 
    @exp = [];
    for 0xa..0x1e -> $oct {
        @exp.push: IP::Addr.new( "2001::" ~ $oct.base(16).lc );
    }   

    is-deeply @res.map( { ~$_ } ), "2001::a-2001::1e" xx 21, "range sequnce";
    is-deeply @res.map( { ~$_.ip } ), @exp.map( { ~$_ } ), "range IP sequnce";
}

# vim: ft=perl6 et sw=4
