use v6;
use Test;
use POFile;

plan *;

my $PO = qq!msgid "One"\nmsgstr ""!;
ok POFile.parse($PO);

$PO = qq!#~ obsolete message!;
ok POFile.parse($PO);

done-testing;
