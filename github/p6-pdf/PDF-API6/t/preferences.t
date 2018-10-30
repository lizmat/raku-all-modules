use v6;
use Test;
use PDF::Grammar::Test :is-json-equiv;
plan 15;
use PDF::API6;
use PDF::Catalog;
use PDF::Destination :Fit;
constant PageLabel = PDF::API6::PageLabel;

my PDF::API6 $pdf .= new;
$pdf.add-page for 1 .. 10;
my $page = $pdf.add-page;
given  $pdf.preferences {
    .HideToolbar = True;
    .OpenAction = $pdf.destination( :page(1), :fit(FitWindow) );
    .PageLayout = 'SinglePage';
    .PageMode = 'UseNone';
    .NonFullScreenPageMode = 'UseNone';
}
my PDF::Catalog $catalog = $pdf.catalog;

is $catalog.PageLayout, 'SinglePage', 'PageLayout';
is $catalog.PageMode, 'UseNone', 'PageMode';
my $viewer-prefs = $catalog.ViewerPreferences;
is $viewer-prefs.HideToolbar, True, 'viewer HideToolbar';
is $viewer-prefs.NonFullScreenPageMode, 'UseNone', 'viewer non-full page-mode';

my $open-action = $catalog<OpenAction>;

isa-ok $open-action, Array, 'OpenAction';
is $open-action.elems, 2, 'OpenAction elems';
is-deeply $open-action[0], $page, 'OpenAction[0]';
is $open-action[1], 'Fit', 'OpenAction[1]';

my @page-labels = 0 => 'i',
                  3 =>  1,
                  6 =>  'A-1',
                  8 =>  'B-1',
                 10 =>  { :style(PageLabel::RomanUpper), :start(1), :prefix<B-> };

$pdf.page-labels = @page-labels;

is-json-equiv $pdf.page-labels, { 0 => {:S<r>, :St(1)},
                                  3 => {:S<D>, :St(1)},
                                  6 => {:P<A->, :S<D>, :St(1)},
                                  8 => {:P<B->, :S<D>, :St(1)},
                                 10 => {:P<B->, :S<R>, :St(1)},
                              }, '.page-labels accessor';

is-json-equiv $pdf.catalog.PageLabels, {
    :Nums[ 0, {:S<r>, :St(1)},
           3, {:S<D>, :St(1)},
           6, {:P<A->, :S<D>, :St(1)},
           8, {:P<B->, :S<D>, :St(1)},
          10, {:P<B->, :S<R>, :St(1)}
        ],
}, '.catalog.PageLabels';

sub dest(|c) { :Dest($pdf.destination(|c)) }

my Pair $dest = dest(:page(3));
is $dest.key, 'Dest', '$dest.key';;
does-ok $dest.value, PDF::Destination['Fit'];
is-deeply $dest.value.page, $pdf.page(3), '$dest.value.page';
is $dest.value.fit, 'Fit', '$dest.value.fit';

lives-ok {
    $pdf.outlines.kids = [
          %( :Title('Table of Contents'),           dest(:page(1))),
          %( :Title('1. Purpose of this Document'), dest(:page(1))),
          %( :Title('2. Pre-requisites'),           dest(:page(2))),
          %( :Title('3. Compiler Speed-up'),        dest(:page(3))),
          %( :Title('4. Recompiling the Kernel for Modules'), dest(:page(4)),
             :kids[
                %( :Title('5.1. Configuring Debian or RedHat for Modules'),
                   dest(:page(5), :fit(FitXYZoom), :top(798)) ),
                %( :Title('5.2. Configuring Slackware for Modules'),
                   dest(:page(5), :fit(FitXYZoom), :top(400)) ),
                %( :Title('5.3. Configuring Other Distributions for Module'),
                   dest(:page(5), :fit(FitXYZoom), :top(200)) ),
              ],
           ),
          %( :Title('Appendix'), dest(:page(7))),
         ];
}, '.kids rw accessor';

$pdf.save-as: "tmp/preferences.pdf";

done-testing;

