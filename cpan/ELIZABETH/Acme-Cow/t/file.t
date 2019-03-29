use v6.c;;
use Test;
plan 16;

use Acme::Cow;

sub compare_bubbles($a,$b) {
    my @a = split("\n", $a);
    my @b = split("\n", $b);
    is +@a, +@b;
    @a>>.chomp;
    @b>>.chomp;
    for ^@a -> $i {
        is @a[$i], @b[$i];
    }
}

my $x = Acme::Cow.new(File => "t/eyes.cow".IO.e ?? "t/eyes.cow" !! "eyes.cow");
$x.text("Bwahaha!");
compare_bubbles($x.as_string, Q:to/EOC/);
 __________
< Bwahaha! >
 ----------
    \
     \
                                   .::!!!!!!!:.
  .!!!!!:.                        .:!!!!!!!!!!!!
  ~~~~!!!!!!.                 .:!!!!!!!!!UWWW$$$ 
      :$$NWX!!:           .:!!!!!!XUWW$$$$$$$$$P 
      $$$$$##WX!:      .<!!!!UW$$$$"  $$$$$$$$# 
      $$$$$  $$$UX   :!!UW$$$$$$$$$   4$$$$$* 
      ^$$$B  $$$$     $$$$$$$$$$$$   d$$R" 
        "*$bd$$$$      '*$$$$$$$$$$$o+#" 
             """"          """"""" 
EOC
$x.print;
