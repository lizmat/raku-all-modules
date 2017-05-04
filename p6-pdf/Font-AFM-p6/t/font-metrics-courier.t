use Test;
plan 8;
%*ENV<METRICS> = 'etc/Core14_AFMs';

require ::('Font::Metrics::courier');
my $metrics = ::('Font::Metrics::courier').new;

is-approx $metrics.stringwidth("Perl", 1), 2.4;
is-deeply $metrics.BBox<P>, [79, 0, 558, 562], 'BBox data';
is-deeply $metrics.FontBBox, [-23, -250, 715, 805], 'FontBBox data';
nok ($metrics.KernData), 'fixed font lacks kern data';
is $metrics.stringwidth("RVX", :!kern), 1800, 'stringwidth :!kern';
is $metrics.stringwidth("RVX", :kern), 1800, 'stringwidth :kern';
is-deeply $metrics.kern("RVX" ), (["RVX"], 1800), '.kern(:kern)';
is-deeply $metrics.kern("RVX", 12), (["RVX"], 1800 * 12 / 1000), '.kern(..., $w))';
