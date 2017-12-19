use v6;
use Test;
use PDF::Class;

# ensure consistant document ID generation
srand(123456);

't/helloworld.pdf'.IO.copy('t/update.pdf');
my $pdf = PDF::Class.open('t/update.pdf');
my $new-page = $pdf.Pages.add-page;
$new-page.gfx.say( 'New Last Page!!' );
ok $pdf.update(:!info), 'update';

$pdf = PDF::Class.open('t/update.pdf');
is $pdf.page-count, 2, 'pdf now has two pages';

ok $pdf.save-as('t/pdf/update-resaved.json', :!info), 'save-as json';

$pdf = PDF::Class.open('t/pdf/update-resaved.json');
is $pdf<Info><Author>, 't/helloworld.t', '$pdf<Info><Author>';
is $pdf<Info><Creator>, 'PDF::Tools', '$pdf<Info><Creator>';
ok my $p2 = $pdf.page(2), 'pdf reload from json';

my $p2-again;
lives-ok {$p2-again = $pdf.delete-page(2)}, 'delete-page lives';
ok $p2 === $p2-again, 'delete page returned';
is $pdf.page-count, 1, 'pages after deletion';

done-testing;
