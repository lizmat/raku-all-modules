use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => EPSILON_SVR,
                                                      kernel-type => LINEAR,
                                                      :probability);
    my @train = (1..100).map: { ((2.0 * $_),"1:$_").join(" ") };
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    my $model = $libsvm.train($problem, $parameter);
    my Pair @test = parse-libsvmformat(@train.pick).head<pairs>.flat;
    my $actual = $model.predict(features => @test)<label>;
    my $expected = 2.0 * @test[0].value;
    my $mae = $model.svr-probability;
    my $std = sqrt(2.0 * $mae * $mae);
    ok $expected - 5.0 * $std <= $actual <= $expected + 5.0 * $std, { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM::Model.predict<label> should predict f(x)" }("EPSILON_SVR/LINEAR");
}

done-testing;
