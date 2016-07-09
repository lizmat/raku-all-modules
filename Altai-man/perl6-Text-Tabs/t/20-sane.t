use v6;

use Test;
use lib 'lib';
use Text::Wrap;

plan 3;

my $columns = 15;
Text::Wrap::<$columns> = 10; # To avoid re-declaration of $columns variable.
ok wrap("\t", "|", "this is a long-long message") eq "        this is a|long-long|message";
ok fill("\t", "|", ["this is a long-long message"]) eq "        this is a|long-long|message";
ok $columns == 15;
