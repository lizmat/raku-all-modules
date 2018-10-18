use File::Ignore;
use Test;

my $ig = File::Ignore.parse(q:to/LIST/);
    result-[AB].txt
    gen[!0].dat
    LIST

ok $ig.ignore-file('result-A.txt'), '"result-[AB].txt" ignores file result-A.txt';
ok $ig.ignore-directory('result-A.txt'), '"result-[AB].txt" ignores directory result-A.txt';
ok $ig.ignore-file('result-B.txt'), '"result-[AB].txt" ignores file result-B.txt';
ok $ig.ignore-directory('result-B.txt'), '"result-[AB].txt" ignores directory result-B.txt';
nok $ig.ignore-file('result-C.txt'), '"result-[AB].txt" does not ignore file result-C.txt';
nok $ig.ignore-directory('result-C.txt'), '"result-[AB].txt" does not ignore directory result-C.txt';
nok $ig.ignore-file('result-.txt'), '"result-[AB].txt" does not ignore file result-.txt';
nok $ig.ignore-directory('result-.txt'), '"result-[AB].txt" does not ignore directory result-.txt';

ok $ig.ignore-file('gen1.dat'), '"gen[!0].dat" ignores file gen1.dat';
ok $ig.ignore-directory('gen1.dat'), '"gen[!0].dat" ignores directory gen1.dat';
ok $ig.ignore-file('genX.dat'), '"gen[!0].dat" ignores file genX.dat';
ok $ig.ignore-directory('genX.dat'), '"gen[!0].dat" ignores directory genX.dat';
nok $ig.ignore-file('gen0.dat'), '"gen[!0].dat" does not ignore file gen0.dat';
nok $ig.ignore-directory('gen0.dat'), '"gen[!0].dat" does not ignore directory gen0.dat';
nok $ig.ignore-file('gen.dat'), '"gen[!0].dat" does not ignore file gen.dat';
nok $ig.ignore-directory('gen.dat'), '"gen[!0].dat" does not ignore directory gen.dat';
nok $ig.ignore-file('gen/.dat'), '"gen[!0].dat" does not ignore file gen/.dat';
nok $ig.ignore-directory('gen/.dat'), '"gen[!0].dat" does not ignore directory gen/.dat';

done-testing;
