use lib <lib>;
use Test::When <author>; # test file creates 'config.json' in CWD
use Testo;
use JSON::Fast;

plan 5;

constant $file = 'config.json'.IO; BEGIN $file.unlink; END $file.unlink;
use Config::JSON;

is $file, *.e, 'config file got created';
is jconf(*), {}, 'Whatever gives empty Hash';

group 'non-existent key' => 3 => {
    my $v := jconf 'foo';
    is $v, Failure, 'returns Failure';
    is $v.exception, Config::JSON::X::NoSuchKey, 'right exception';
    is $v.handled, *.not, 'non-existent key returns unhandled Failure';
}

group 'write string' => 3 => {
    jconf-write 'bar', 'meow';
    is $file.slurp.&from-json, {bar => 'meow'}, 'data got saved to file';
    is jconf('bar'), 'meow', 'key is readable';
    is jconf(*), {bar => 'meow'}, 'Whatever gives Hash with stuff';
}

group 'write complex structure' => 3 => {
    my $v   = [meow => [<a b c>, {:42a, :70b}]];
    my $all = {
        :bar("meow"), :bez($[{:meow($[["a", "b", "c"], {:a(42), :b(70)}])},])
    };
    jconf-write 'bez', $v<>;
    is $file.slurp.&from-json, $all, 'data got saved to file';
    is jconf('bez'), $v, 'key is readable';
    is jconf(*), $all, 'Whatever gives Hash with stuff';
}
