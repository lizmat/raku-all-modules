use lib <lib>;
use Testo;
use JSON::Fast;
use Temp::Path;

plan 6;

constant $file = make-temp-path;
constant $default-file = 'config.json'.IO;
constant $was-there = $default-file.e;
use Config::JSON '';
is $default-file.e === $was-there, *.so, 'default file was not created';

group 'reading without file' => 3 => {
    is $file, *.e.not, 'config file did not get auto created';

    group 'reading key' => 3 => {
        my $v := jconf $file, 'foo';
        is $v, Failure, 'returns Failure';
        is $v.exception, Config::JSON::X::Open, 'right exception';
        is $v.handled, *.not, 'non-existent key returns unhandled Failure';
    }

    group 'writing key' => 3 => {
        my $v := jconf-write $file, 'foo', 'bar';
        is $v, Failure, 'returns Failure';
        is $v.exception, Config::JSON::X::Open, 'right exception';
        is $v.handled, *.not, 'non-existent key returns unhandled Failure';
    }
}

$file.spurt: '{}';
is jconf($file, *), {}, 'Whatever gives empty Hash';

group 'non-existent key' => 3 => {
    my $v := jconf $file, 'foo';
    is $v, Failure, 'returns Failure';
    is $v.exception, Config::JSON::X::NoSuchKey, 'right exception';
    is $v.handled, *.not, 'non-existent key returns unhandled Failure';
}

group 'write string' => 3 => {
    jconf-write $file, 'bar', 'meow';
    is $file.slurp.&from-json, {bar => 'meow'}, 'data got saved to file';
    is jconf($file, 'bar'), 'meow', 'key is readable';
    is jconf($file, *), {bar => 'meow'}, 'Whatever gives Hash with stuff';
}

group 'write complex structure' => 3 => {
    my $v   = [meow => [<a b c>, {:42a, :70b}]];
    my $all = {
        :bar("meow"), :bez($[{:meow($[["a", "b", "c"], {:a(42), :b(70)}])},])
    };
    jconf-write $file, 'bez', $v<>;
    is $file.slurp.&from-json, $all, 'data got saved to file';
    is jconf($file, 'bez'), $v, 'key is readable';
    is jconf($file, *), $all, 'Whatever gives Hash with stuff';
}
