use Test;
plan 8;
%*ENV<METRICS> = 'etc/Core14_AFMs';

require ::('Font::Metrics::times-roman');
my $metrics = ::('Font::Metrics::times-roman').new;

is_approx $metrics.stringwidth("Perl", 1), 1.611;
is-deeply $metrics.BBox<P>, [16, 0, 542, 662], 'BBox data';
is $metrics.KernData<R><V>, -80, 'kern data';
nok ($metrics.KernData<V><X>:exists), 'kern data (missing)';
is $metrics.stringwidth("RVX", :!kern), 2111, 'stringwidth :!kern';
is $metrics.stringwidth("RVX", :kern), 2111 - 80, 'stringwidth :kern';
is-deeply $metrics.kern("RVX" ), ["R", -80, "VX"], '.kern(:kern)';
is-deeply $metrics.kern("RVX", 12), ["R", -0.96, "VX"], '.kern(..., $w))';

