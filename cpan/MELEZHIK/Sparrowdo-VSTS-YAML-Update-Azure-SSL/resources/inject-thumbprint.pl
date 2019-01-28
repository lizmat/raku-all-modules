use strict;

use JSON;

my $dir = $ARGV[0];

open F, "$dir/cert.json" or die $!;
my $json = join "", <F>; 
close F;

my $data = decode_json($json);

print "cert data:\n$json\n\n";

print "x509ThumbprintHex:\t", $data->{x509ThumbprintHex}, "\n";
print "Expires:\t\t", $data->{attributes}->{expires}, "\n";
print "dnsNames:\t\t", join " ", @{$data->{policy}->{x509CertificateProperties}->{subjectAlternativeNames}->{dnsNames}}, "\n";

print "\n\n";

my $tp = $data->{x509ThumbprintHex};

# update create-cert.json
open F, "$dir/create-cert.json" or die $!;
my $d = join "", <F>; 
close F;

$d=~s/__thumbprint__/$tp/g;

open F, ">", "$dir/create-cert.json" or die $!;
print F $d;
close F;

print "update [create-cert.json] OK:\n$d\n\n";

# update update-cert.json
open F, "$dir/update-cert.json" or die $!;
my $d = join "", <F>; 
close F;

$d=~s/__thumbprint__/$tp/g;

open F, ">", "$dir/update-cert.json" or die $!;
print F $d;
close F;

print "update [update-cert.json] OK:\n$d\n\n"


