use v6;
use PDF::Font::Loader;
use PDF::Lite;
use Test;
# ensure consistant document ID generation
srand(123456);
my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
my @differences = 1, 'b', 'c', 10, 'y', 'z';
my $times = PDF::Font::Loader.load-font( :file<t/fonts/TimesNewRomPS.pfb>, :@differences );
is-deeply $times.encode('abcdxyz'), buf8.new(97,1,2,100,120,10,11), 'differences encoding';
$page.text: {
    .text-position = 10,500;
    .font = $times;
    .say: "encoding check: abcdxyz";;
}
lives-ok { $pdf.save-as: "t/type1-encoding.pdf"; };

done-testing;

