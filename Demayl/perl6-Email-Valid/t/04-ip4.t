use v6;
use Test;

plan 5;

use Email::Valid;

my $public = Email::Valid.new( :allow-ip );

my @ipv4_valid     = Q:w/ab@[123.123.0.101] ab@[1.1.1.3] cc@[210.15.18.24]/;
my @ipv4_invalid   = Q:w/ab@[a.b.c.d] ab@[1.2.3.256] ab@1.2.3.4] ab@[1.2.3.4 ab@[0.1.2.3] ab@[0.0.0.0] ab@[1.2.3.0] ab@[127.0.0.1] ab@[10.0.0.10] 
ab@1.1.1.1 ab@[172.17.17.17] ab@[192.168.10.110] ab@[255.255.255.255] zz@[] zz@[0] zz@[1.2] zz@[1.2.3] zz@[0.1.2.3]/;


is [ @ipv4_valid.map({ $public.validate( $_ ) }) ],  [ True xx @ipv4_valid.elems ],    'Valid IPv4';
is [ @ipv4_invalid.map({ $public.validate( $_ ) }) ],[ False xx @ipv4_invalid.elems ], 'Invalid IPv4';


my $local = Email::Valid.new( :allow-ip, :allow-local );


@ipv4_valid     = Q:w/ab@[10.123.0.101] ab@[192.168.1.3] cc@[127.0.0.1] cc@[172.23.0.1]/;
@ipv4_invalid   = Q:w/zz@[10.0.0.0] zz@[192.168.15.0] mm@[172.31.31.0] mm@[224.2.1.3] ee@[240.1.1.1] zz@[] zz@[0]/;

is [ @ipv4_valid.map({ $local.validate( $_ ) }) ],  [ True xx @ipv4_valid.elems ],    'Valid local IPv4';
is [ @ipv4_invalid.map({ $local.validate( $_ ) }) ],[ False xx @ipv4_invalid.elems ], 'Invalid local IPv4';

my $no-ip = Email::Valid.new();


my @ipv4 = Q:w/ab@[123.123.0.101] ab@[1.1.1.3] cc@[210.15.18.24] ab@[10.123.0.101] ab@[192.168.1.3] cc@[127.0.0.1] cc@[172.23.0.1]
    zz@[10.0.0.0] zz@[192.168.15.0] mm@[172.31.31.0] mm@[224.2.1.3] ab@[1.2.3.256] ab@[255.255.255.255] zz@[10.0.0.0] zz@[]/;

is [ @ipv4.map({ $no-ip.validate( $_ ) }) ], [ False xx @ipv4.elems ], 'Disabled IPv4';
