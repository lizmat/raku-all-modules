use v6;
use Test;
use PDF::Class;
use PDF::Destination :Fit, :DestinationLike;
use PDF::Page;
use PDF::COS::Name;

multi sub is-destination(PDF::Destination $dest, $expected, $reason = 'destination') {
    use PDF::Grammar::Test :is-json-equiv;
    $dest.check;
    is-json-equiv($dest, $expected, $reason);
}
multi sub is-destination($_, $, $reason) is default {
    flunk($reason);
    note "{.perl} is not a valid destination";
}

my PDF::Page $page .= new: :dict{ :Type<Page> };
my $dest = [$page, 'Fit'];

ok $dest ~~ DestinationLike, 'is destination array';
ok [$page, 'Blah'] !~~ DestinationLike, 'non-destination array';

my PDF::Destination $d;
is-destination $d=PDF::Destination.construct(FitWindow, :$page), [$page, FitWindow], 'FitWindow destination';
is-deeply $d.page, $page, 'page accessor';
is $d.fit, 'Fit', 'fit accessor';
is $d.is-page-ref, True, 'destination is page ref';
does-ok $d.fit, PDF::COS::Name, 'fit accessor';
is-deeply $d.content, (:array($[:dict{:Type(:name<Page>)}, :name<Fit>])), 'destination content';

is-destination $d=PDF::Destination.construct(:$page), [$page, FitWindow], 'Default destination';
is-deeply $d.page, $page, 'page accessor';
is $d.fit, 'Fit', 'fit accessor';
is $d.is-page-ref, True, 'destination is page ref';
does-ok $d.fit, PDF::COS::Name, 'fit accessor';
is-deeply $d.content, (:array($[:dict{:Type(:name<Page>)}, :name<Fit>])), 'destination content';

is-destination $d=PDF::Destination.construct(:page(3)), [3, FitWindow], 'page number destination';
is-deeply $d.page, 3, 'page-number page accessor';
is $d.fit, 'Fit', 'page-number fit accessor';
is $d.is-page-ref, False, 'destination is page ref';
does-ok $d.fit, PDF::COS::Name, 'fit accessor';
is-deeply $d.content, (:array($[:int(3), :name<Fit>])), 'destination content';

is-destination $d=PDF::Destination.construct(FitXYZoom, :$page, :left(42), :top(99), :zoom(1.5)), [$page, FitXYZoom, 42, 99, 1.5], 'FitXYZoom destination';
is $d.left, 42, 'left accessor';
is $d.top, 99, 'top accessor';
is $d.zoom, 1.5, 'zoom accessor';

is-destination $d=PDF::Destination.construct(FitHoriz, :$page, :top(99), ), [$page, FitHoriz, 99,], 'FitHoriz destination';
is $d.top, 99, 'top accessor';

is-destination $d=PDF::Destination.construct(FitVert, :$page, :left(42), ), [$page, FitVert, 42,], 'FitVert destination';
is $d.left, 42, 'left accessor';

is-destination $d=PDF::Destination.construct(FitRect, :$page, :left(42), :top(99), :bottom(10), :right(100)), [$page, FitRect, 42, 10, 100, 99], 'FitRect destination';
is $d.left, 42, 'left accessor';
is $d.top, 99, 'top accessor';
is $d.bottom, 10, 'bottom accessor';
is $d.right, 100, 'right accessor';

is-destination $d=PDF::Destination.construct(FitBox, :$page), [$page, FitBox], 'FitBox destination';
is $d.fit, FitBox, 'fit accessor';

is-destination $d=PDF::Destination.construct(FitBox, :page(42)), [42, FitBox], 'FitBox destination';
is $d.is-page-ref, False, 'destination is not a page ref';
is $d.page, 42, 'destination page';
is $d.fit, FitBox, 'fit accessor';

done-testing;
