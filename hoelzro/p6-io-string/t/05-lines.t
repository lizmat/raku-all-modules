use v6;
use Test;
use IO::String;

plan 16;

# lines, unix, chomp
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    ok !$s.eof, "not yet eof";
    my @lines = $s.lines;
    is @lines[0], "hello,", "got first line";
    is @lines[1], "world!", "got second line";
    ok $s.eof, "we have eof";
}

# lines, dos, chomp
{
    my $s = IO::String.new(buffer => "hello,\r\nworld!\r\n");
    ok !$s.eof, "not yet eof";
    my @lines = $s.lines;
    is @lines[0], "hello,", "got first line";
    is @lines[1], "world!", "got second line";
    ok $s.eof, "we have eof";
}

# lines, unix, !chomp
{
    my $s = IO::String.new(buffer => "hello,\nworld!\n", :!chomp);
    ok !$s.eof, "not yet eof";
    my @lines = $s.lines;
    is @lines[0], "hello,\n", "got first line";
    is @lines[1], "world!\n", "got second line";
    ok $s.eof, "we have eof";
}

# lines, dos, !chomp
{
    my $s = IO::String.new(buffer => "hello,\r\nworld!\r\n", :!chomp);
    ok !$s.eof, "not yet eof";
    my @lines = $s.lines;
    is @lines[0], "hello,\r\n", "got first line";
    is @lines[1], "world!\r\n", "got second line";
    ok $s.eof, "we have eof";
}
