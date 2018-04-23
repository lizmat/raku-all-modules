use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 2;

# is-approx because we use `now` to gen durations
my $abs-tol := 1;
is-approx GCT.new('D21.18/65:437 GCT' ).Instant.Rat, :$abs-tol,
          GCT.now.later(:21cycles).later(:18days).later(:65segments)
          .later(:437units).Instant.Rat, 'later';
is-approx GCT.new('D-21.18/65:437 GCT' ).Instant.Rat, :$abs-tol,
          GCT.now.earlier(:21cycles).earlier(:18days).earlier(:65segments)
          .earlier(:437units).Instant.Rat, 'earlier';
