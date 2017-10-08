#!/usr/bin/env perl

# this is a Perl 5 program

use strict;
use warnings;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

#http://www.ngs.noaa.gov/cgi-bin/Inv_Fwd/forward2.prl
#http://www.ngs.noaa.gov/cgi-bin/Inv_Fwd/inverse2.prl

my $uf = 'http://www.ngs.noaa.gov/cgi-bin/Inv_Fwd/forward2.prl';
my $ui = 'http://www.ngs.noaa.gov/cgi-bin/Inv_Fwd/inverse2.prl';

my $ua = LWP::UserAgent->new();

get_forward();
get_inverse();

sub get_forward {
  # forward
  my $req = POST $uf, [
    ELLIPSOID => 'GRS80/WGS84',

    FROM_NAME => 'from',
    FIRST_LAT => 'N01.0',
    FIRST_LON => 'e00.0',
    AZIMUTH   => '120.0',
    DIST      => '10000.0',

    TO_NAME   => 'to',
  ];

  my $res = $ua->request($req)->as_string;

  parse($res);
  #print $res;

=pod

# example raw output (unneeded stripped away)

<h2>Output from FORWARD</h2><pre>

  Ellipsoid : GRS80 / WGS84  (NAD83)
  Equatorial axis,    a   =    6378137.0000
  Polar axis,         b   =    6356752.3141
  Inverse flattening, 1/f =  298.25722210088

  First  Station : from
   ----------------
    LAT =   1  0  0.00000 North
    LON =   0  0  0.00000 East

  Second Station : to
   ----------------
    LAT =   0 57 17.21068 North
    LON =   0  4 40.10559 East

  Forward azimuth        FAZ = 120  0  0.0000 From North
  Back azimuth           BAZ = 300  0  4.7780 From North
  Ellipsoidal distance     S =     10000.0000 m

=cut

}

sub get_inverse {
  my $req = POST $ui, [
    ELLIPSOID => 'GRS80/WGS84',

    FROM_NAME => 'from',
    FIRST_LAT => 'N01.0',
    FIRST_LON => 'e00.0',

    TO_NAME   => 'to',
    SECOND_LAT => 'S01.0',
    SECOND_LON => 'w00.0',
  ];

  my $res = $ua->request($req)->as_string;
  print $res;

=pod

# example raw output (unneeded stripped away)

<h2>Output from INVERSE </h2><pre>

  Ellipsoid : GRS80 / WGS84  (NAD83)
  Equatorial axis,    a   =    6378137.0000
  Polar axis,         b   =    6356752.3141
  Inverse flattening, 1/f =  298.25722210088

  First  Station : from
   ----------------
    LAT =   1  0  0.00000 North
    LON =   0  0  0.00000 East

  Second Station : to
   ----------------
    LAT =   1  0  0.00000 South
    LON =   0  0  0.00000 East

  Forward azimuth        FAZ = 180  0  0.0000 From North
  Back azimuth           BAZ =   0  0  0.0000 From North
  Ellipsoidal distance     S =    221148.7771 m

=cut

}

sub parse {
  my $s = shift @_;
  # split on newline
  my @lines = split /^/, $s;

  foreach my $line (@lines) {
    chomp $line;
    if ($line =~ m{ Output \s+ from \s+ (INVERSE|FORWARD)}xms) {
      my $dir = $1;
      print "DEBUG: $line\n";
      print "  ($dir)\n";
    }
    elsif ($line =~ m{\A \s* Ellipsoid \s \: \s* ([\S\s]+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1)\n";
    }
    elsif ($line =~ m{\A \s* Equatorial \s axis, \s+ a \s+ = \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1)\n";
    }
    elsif ($line =~ m{\A \s* Polar \s axis, \s+ b \s+ = \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1)\n";
    }
    elsif ($line =~ m{\A \s* Inverse \s flattening, \s+ 1/f \s+ = \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1)\n";
    }
    elsif ($line =~ m{\A \s* (LAT|LON) \s+ = \s+ (\S+) \s+ (\S+) \s+ (\S+) \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1) ($2) ($3) ($4) ($5)\n";
    }
    elsif ($line =~ m{\A \s* (Forward|Back) \s azimuth \s+ (FAZ|BAZ) \s = \s+ (\S+) \s+ (\S+) \s+ (S+) \s+ (\S+) \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1) ($2) ($3) ($4) ($5) ($6) ($7)\n";
    }
    elsif ($line =~ m{\A \s* Ellipsoidal \s distance \s+ S \s+ = \s+(\S+) \s+ (\S+) \s* \z}xms) {
      print "DEBUG: $line\n";
      print "  ($1) ($2)\n";
    }

    #chomp $line;
    #print "  $line\n";
  }
  die "DEBUG exit";
}
