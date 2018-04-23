use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 10;

is-deeply GCT.new('21.18/65:437 GCT'), GCT.new('021.18/65:437 GCT'), 'X';
is-deeply GCT.new('1.18/65:437 GCT'), GCT.new('001.18/65:437 GCT'), 'XX';
is-deeply GCT.new('18/65:437 GCT'), GCT.new('000.18/65:437 GCT'), 'XXX.';
is-deeply GCT.new('8/65:437 GCT'), GCT.new('000.08/65:437 GCT'), 'XXX.X';
is-deeply GCT.new('/65:437 GCT'), GCT.new('000.00/65:437 GCT'), 'XXX.XX';

# is-approx because we use `now` to gen durations
my $abs-tol := 1;
is-approx GCT.new('D21.18/65:437 GCT' ).Instant.Rat, :$abs-tol,
          GCT.new('D021.18/65:437 GCT').Instant.Rat, 'DX';
is-approx GCT.new('D1.18/65:437 GCT'  ).Instant.Rat, :$abs-tol,
          GCT.new('D001.18/65:437 GCT').Instant.Rat, 'DXX';
is-approx GCT.new('D18/65:437 GCT'    ).Instant.Rat, :$abs-tol,
          GCT.new('D000.18/65:437 GCT').Instant.Rat, 'DXXX.';
is-approx GCT.new('D8/65:437 GCT'     ).Instant.Rat, :$abs-tol,
          GCT.new('D000.08/65:437 GCT').Instant.Rat, 'DXXX.X';
is-approx GCT.new('D/65:437 GCT'      ).Instant.Rat, :$abs-tol,
          GCT.new('D000.00/65:437 GCT').Instant.Rat, 'DXXX.XX';
