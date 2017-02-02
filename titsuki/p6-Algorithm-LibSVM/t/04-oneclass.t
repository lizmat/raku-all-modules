use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

sub gen-train {
    my $max-x = 0.5;
    my $min-x = -0.5;
    my $max-y = 0.5;
    my $min-y = -0.5;
    do for ^300 {
        my $x = $min-x + rand * ($max-x - $min-x);
        my $y = $min-y + rand * ($max-y - $min-y);
        my $label = do given $x, $y {
            when $x ** 2 + $y ** 2 <= 0.3 ** 2 {
                1
            }
            default { Nil }
        }
        ($label,"1:$x","2:$y") if $label.defined;
    }.sort({ $^a.[0] cmp $^b.[0] })>>.join(" ")

}
my @train = gen-train;

my Pair @test-in = parse-libsvmformat(q:to:c/END/).head<pairs>.flat;
1 1:{sqrt(0)} 2:{sqrt(0)}
END

my Pair @test-out = parse-libsvmformat(q:to:c/END/).head<pairs>.flat;
1 1:{sqrt(10)} 2:{sqrt(10)}
END

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => ONE_CLASS,
                                                      kernel-type => RBF,
                                                      nu => 1e-2);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("ONE_CLASS/RBF");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-in)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center in the training set), it should return 1.0e0" }("ONE_CLASS/RBF");
    is $model.predict(features => @test-out)<label>, -1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance keeps at a distance from the center in the training set), it should return -1.0e0" }("ONE_CLASS/RBF");
}

done-testing;
