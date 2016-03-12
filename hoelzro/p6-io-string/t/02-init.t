use v6;
use Test;
use IO::String;

plan 3;

subtest {
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    is $s.buffer, "hello,\nworld!\n";
    is $s.pos, 0;
}, 'setup with new';

subtest {
    my $s = IO::String.new;
    $s.open("hello,\nworld!\n");
    is $s.buffer, "hello,\nworld!\n";
    is $s.pos, 0;
}, 'setup with open';

subtest {
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    $s.open;
    is $s.buffer, '';
    is $s.pos, 0;
}, 'setup with string and then open with no args';
