use v6;
use Test;
use PDF::Class;
use PDF::Page;

't/helloworld.pdf'.IO.copy('t/update.pdf');
my PDF::Class $pdf .= open('t/update.pdf');
my $new-page = $pdf.Pages.add-page;
$new-page.gfx.say( 'New Last Page!!' );
# ensure consistant document ID generation
srand(123456);
ok $pdf.update(:!info), 'update';

$pdf .= open('t/update.pdf');
is $pdf.page-count, 2, 'pdf now has two pages';

ok $pdf.save-as('tmp/update-resaved.json', :!info), 'save-as json';

$pdf .= open('tmp/update-resaved.json');
is $pdf<Info><Author>, 't/helloworld.t', '$pdf<Info><Author>';
is $pdf<Info><Creator>, 'PDF::Class', '$pdf<Info><Creator>';
ok my PDF::Page $p2 = $pdf.page(2), 'pdf reload from json';

my PDF::Page $p2-again;
lives-ok {$p2-again = $pdf.delete-page(2)}, 'delete-page lives';
ok $p2 === $p2-again, 'deleted page returned';
is $pdf.page-count, 1, 'pages after deletion';

done-testing;
