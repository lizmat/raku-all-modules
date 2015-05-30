use Test;
plan 10;
%*ENV<METRICS> = 'etc/Core14_AFMs';

require ::('Font::Metrics::times-roman');
my $metrics = ::('Font::Metrics::times-roman').new;

is_approx $metrics.stringwidth("Perl",1), 1.611;
is-deeply $metrics.BBox<P>, [16, 0, 542, 662], 'BBox data';
is $metrics.KernData<R><V>, -80, 'kern data';
nok ($metrics.KernData<V><X>:exists), 'kern data (missing)';
is $metrics.stringwidth("RVX", :!kern), 2111, 'stringwidth :!kern';
is $metrics.stringwidth("RVX", :kern), 2111 - 80, 'stringwidth :kern';
is-deeply $metrics.encode("RVX"), [["RVX", 2111.0, 0]], '.encode';
is-deeply $metrics.encode("RVX", :!kern), [["RVX", 2111.0, 0]], '.encode';
is-deeply $metrics.encode("RVX", :kern), [["R", 667.0, -80], ["VX", 1444.0, 0]], '.encode(:kern)';
is-deeply $metrics.encode("RVX", 12, :kern), [["R", 8.004, -0.96], ["VX", 17.328, 0]], '.encode($widthm :kern)';

