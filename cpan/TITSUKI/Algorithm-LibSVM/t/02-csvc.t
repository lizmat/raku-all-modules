use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

sub gen-train {
    my $max-x = 1;
    my $min-x = -1;
    my $max-y = 1;
    my $min-y = -1;

    do for ^300 {
        my $x = $min-x + rand * ($max-x - $min-x);
        my $y = $min-y + rand * ($max-y - $min-y);

        my $label = do given $x, $y {
            when ($x - 0.5) ** 2 + ($y - 0.5) ** 2 <= 0.2 {
                1
            }
            when ($x - -0.5) ** 2 + ($y - -0.5) ** 2 <= 0.2 {
                2
            }
            default { Nil }
        }
        ($label,"1:$x","2:$y") if $label.defined;
    }.sort({ $^a.[0] cmp $^b.[0] })>>.join(" ")
}

my Str @train = gen-train;

my Pair @test = parse-libsvmformat(q:to/END/).head<pairs>.flat;
1 1:0.5 2:0.5
END


{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/LINEAR");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/LINEAR");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/LINEAR/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/LINEAR/:probability");
    ok $model.predict(features => @test, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/LINEAR/:probability");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => POLY);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/POLY");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/POLY");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => POLY,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/POLY/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/POLY/:probability");
    ok $model.predict(features => @test, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/POLY/:probability");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => RBF);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/RBF");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/RBF");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => RBF,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/RBF/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/RBF/:probability");
    ok $model.predict(features => @test, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/RBF/:probability");
}


{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => SIGMOID);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/SIGMOID");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/SIGMOID");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => SIGMOID,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/SIGMOID/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/SIGMOID/:probability");
    ok $model.predict(features => @test, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/SIGMOID/:probability");
}

{
    my @tmp = @train>>.split(" ");
    my Str @train-matrix = gather for @tmp.pairs -> (:key($index-f), :value(@x)) {
        my $f1 = @x[1].split(":")[0] => @x[1].split(":")[1];
        my $f2 = @x[2].split(":")[0] => @x[2].split(":")[1];

        my @result;
        @result.push(@x[0]);
        @result.push(0 ~ ":" ~ $index-f + 1);
        for @tmp.pairs -> (:key($index-t), :value(@y)) {
            my $t1 = @y[1].split(":")[0] => @y[1].split(":")[1];
            my $t2 = @y[2].split(":")[0] => @y[2].split(":")[1];
            @result.push($index-t + 1 ~ ":" ~ $f1.value * $t1.value + $f2.value * $t2.value);
        }
        take @result.join(" ");
    }

    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => PRECOMPUTED);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train-matrix);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/PRECOMPUTED");
    my $model = $libsvm.train($problem, $parameter);
    my Pair @test-matrix = @train-matrix.[0]\
    .split(" ", 2)[1].split(" ")>>.split(":").map: { .[0].Int => .[1].Num };
    is $model.predict(features => @test-matrix.item)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/PRECOMPUTED");
}

done-testing;
