use v6;
use Test;

use META6::To::Man;


my $exe = './bin/meta6-to-man';
my $m   = './t/data/META6.json';
my $m2  = './t/data/META6.json.invalid';


# invalid args
my @bad =
"debug"
, "--meta6"
, "-meta6=$m"
, "--date=687-8-12"
, "--meta6=$m2"
, "--meta6=$m --install"
;
my $nbad = @bad.elems;;

# valid args
my @good =
""
, "--install-to=/tmp"
, "--date=2017-09-09"
;
my $ngood = @good.elems;;

plan $nbad + $ngood;

for @bad {
    my $cmd = "$exe $_";
    dies-ok { shell $cmd }, "invalid args";
}

# ensure valid args start with the mandatory arg
$exe ~= " --meta6=$m";
my $man = 'example.1';
for @good {
    my $cmd = "$exe $_ --man=$man";
    lives-ok { run $cmd.words }, "valid args";
}

# clean up
unlink $man if $man.IO.f;
