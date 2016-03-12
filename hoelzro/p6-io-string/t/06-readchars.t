use v6;
use Test;
use IO::String;

plan 22;

# readchars
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    ok !$s.eof, "not yet eof";
    is $s.readchars(10), "hello,\nwor", 'read 10 characters';
    ok !$s.eof, "not yet eof";
    is $s.readchars(10), "ld!\n", 'read <10 characters';
    ok $s.eof, "we have eof";
}

# readchars and seek
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    ok !$s.eof, "not yet eof";
    is $s.readchars(10), "hello,\nwor", 'read first 10 characters';
    is $s.tell, 10, 'tell is 10';
    ok !$s.eof, "not yet eof";
    $s.seek(-3, SeekFromCurrent);
    is $s.tell, 7, 'tell is 7';
    is $s.readchars(10), "world!\n", 'read last 7 characters';
    is $s.tell, 14, 'tell is 14';
    ok $s.eof, "we have eof";
    $s.seek(0);
    is $s.tell, 0, 'tell is 0';
    is $s.readchars(10), "hello,\nwor", 'read first 10 characters again';
    is $s.tell, 10, 'tell is 10 again';
    ok !$s.eof, "not eof anymore";
    $s.seek(-10, SeekFromEnd);
    is $s.tell, 4, 'tell is 4';
    is $s.readchars(10), "o,\nworld!\n", 'read last 10 characters';
    is $s.tell, 14, 'tell is 14';
    ok $s.eof, "we have eof again";

    is $s.readchars(1), Str, 'read when EOF';
}
