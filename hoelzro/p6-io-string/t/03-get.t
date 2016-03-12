use v6;
use Test;
use IO::String;

plan 24;

# get, unix, chomp
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}

# get, dos, chomp
{
    my $s = IO::String.new(buffer => "hello,\r\nworld!\r\n");
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}

# get, unix, !chomp
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n", :!chomp);
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,\n", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!\n", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}

# get, dos, !chomp
{
    my $s = IO::String.new(buffer => "hello,\r\nworld!\r\n", :!chomp);
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,\r\n", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!\r\n", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}
