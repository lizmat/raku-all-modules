use v6;
use Test;

plan 1;
skip-rest('Will not pass yet');
exit;

# use Data::Dump qw( dump );

use lib 'lib';

# use DNS::Zone::Grammars::Modern;
# use DNS::Zone::Grammars::ModernActions;
# use ResourceRecordDataA;

# my $rr  = ResourceRecord.new;
# my $rra = ResourceRecordDataA.new(ipAdress => '10.0.0.1');

# say $rra.ipAdress;
# dump( $rra );

# my $actions = DNS::Zone::Grammars::ModernActions.new;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
# my $data = $fh.slurp-rest;
# my $match = DNS::Zone::Grammars::Modern.parse($data, :$actions);
# 
# # say $match;
# my $rr = ResourceRecord.new( domainName => 'new',
# 	class => 'IN',
# 	ttl   => 3600,
# 	type  => 'A',
# 	rdata => ResourceRecordDataA.new( ipAdress => '10.0.0.1' )
# );
# $match.made.addResourceRecord(rr => $rr, position => 3);
# 
# say $match.made.gen();
