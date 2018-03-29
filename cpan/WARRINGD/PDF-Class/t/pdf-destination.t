use v6;
use Test;
use PDF::Class;
use PDF::Destination :Fit, :DestinationArray;
use PDF::Page;

multi sub is-destination(PDF::Destination $dest, $expected, $reason = 'destination') {
    use PDF::Grammar::Test :is-json-equiv;
    is-json-equiv($dest, $expected, $reason);
}
multi sub is-destination($_, $, $reason) is default {
    flunk($reason);
    note "{.perl} is not a valid destination";
}

my $page = PDF::Page.new;
my $dest = [$page, 'Fit'];

ok $dest ~~ DestinationArray, 'is destination array';
ok [$page, 'Blah'] !~~ DestinationArray, 'non-destination array';

is-destination PDF::Destination.construct(FitWindow, :$page), [$page, FitWindow], 'FitWindow destination';
is-destination PDF::Destination.construct(FitXYZoom, :$page, :left(42), :top(99), :zoom(1.5)), [$page, FitXYZoom, 42, 99, 1.5], 'FitXYZoom destination';
is-destination PDF::Destination.construct(FitHoriz, :$page, :top(99), ), [$page, FitHoriz, 99,], 'FitHoriz destination';
is-destination PDF::Destination.construct(FitVert, :$page, :left(42), ), [$page, FitVert, 42,], 'FitVert destination';
is-destination PDF::Destination.construct(FitRect, :$page, :left(42), :top(99), :bottom(10), :right(100)), [$page, FitRect, 42, 10, 100, 99], 'FitRect destination';
is-destination PDF::Destination.construct(FitBox, :$page), [$page, FitBox], 'FitBox destination';

done-testing;
