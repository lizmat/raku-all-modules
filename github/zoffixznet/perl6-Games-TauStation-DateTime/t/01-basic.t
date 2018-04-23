use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 15;
isa-ok GCT, DateTime;

is-deeply GCT.new('198.14/07:106GCT'),
          GCT.new('198.14/07:106 GCT'), '198.14/07:106GCT';
is-deeply GCT.new('198.14/07:106 GCT'),
          GCT.new('198.14/07:106 GCT'), '198.14/07:106 GCT';
is-deeply GCT.new(' - 198 . 14 / 07 : 106 GCT').gist,
          GCT.new('-198.14/07:106 GCT').gist, ' - 198 . 14 / 07 : 106 GCT';
is-deeply GCT.new(' 14/07:106 GCT'),
          GCT.new('14/07:106 GCT'), ' 14/07:106 GCT';
is-deeply GCT.new('198.14/07:106 GCT'),
          GCT.new('198.14/07:106 GCT'), '198.14/07:106 GCT';
is-deeply GCT.new(' /07:106 GCT'),
          GCT.new('/07:106 GCT'), ' /07:106 GCT';
is-deeply GCT.new('-/07:106 GCT'),
          GCT.new('-/07:106 GCT'), '-/07:106 GCT';

# is-approx because we use `now` to gen durations
my $abs-tol := 1;
is-approx GCT.new('D198.14/07:106GCT').Instant.Rat, :$abs-tol,
    GCT.now.later(:198cycles).later(:14days).later(:7segments)
    .later(:106units).Instant.Rat, 'D198.14/07:106GCT';
is-approx GCT.new('D198.14/07:106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.later(:198cycles).later(:14days).later(:7segments)
    .later(:106units).Instant.Rat, 'D198.14/07:106 GCT';
is-approx GCT.new('D - 198 . 14 / 07 : 106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.earlier(:198cycles).earlier(:14days).earlier(:7segments)
    .earlier(:106units).Instant.Rat, 'D - 198 . 14 / 07 : 106 GCT';
is-approx GCT.new('D 14/07:106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.later(:14days).later(:7segments).later(:106units).Instant.Rat,
    'D 14/07:106 GCT';
is-approx GCT.new('D-14/07:106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.earlier(:14days).earlier(:7segments).earlier(:106units).Instant.Rat,
    'D-14/07:106 GCT';
is-approx GCT.new('D /07:106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.later(:7segments).later(:106units).Instant.Rat,
    'D /07:106 GC';
is-approx GCT.new('D-/07:106 GCT').Instant.Rat, :$abs-tol,
    GCT.now.earlier(:7segments).earlier(:106units).Instant.Rat;
