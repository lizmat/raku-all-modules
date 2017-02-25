use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

subtest {
    
my \myhash = parse-libsvmformat(q:to/END/);
1 1:0.5 2:0.6
2 1:0.2 2:0.3
END

is myhash[0]<label>, 1;
is myhash[1]<label>, 2;

ok myhash[0]<pairs> ~~ (1 => 0.5, 2 => 0.6);
ok myhash[1]<pairs> ~~ (1 => 0.2, 2 => 0.3);

}, "parse-libsvmformat should parse valid-format input";

dies-ok {

my Pair @test = parse-libsvmformat(q:to/END/).head<pairs>.flat;
1 1;0.5 2:0.5
END

}, "Cannot use ; as a delimiter";

dies-ok {

my Pair @test = parse-libsvmformat(q:to/END/).head<pairs>.flat;
1 1:0.52:0.5
END

}, "Cannot use integer:number:number form";

done-testing;
