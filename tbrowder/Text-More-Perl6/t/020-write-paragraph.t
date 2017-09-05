use v6;
use Test;

use Text::More :ALL;

plan 19;

# input: 10 five-letter words in a string
my @text;
@text.push: ' words';
for 1..^10 -> $i {
    my $s = ' ' x $i;
    $s ~= 'words';
    @text.push: $s;
}
@text.push: ' ';

my $f = '.tmp-030';

# test against some strings
my (@para, @p1);

#============================================================================================
# the string output version

# test 1
{
    @para = write-paragraph(@text, :max-line-length(30));

    @p1 =
    "words words words words words",
    "words words words words words";

    is-deeply @para, @p1;
}

# test 2
{
    @para = write-paragraph(@text, :max-line-length(24));

    @p1 =
    "words words words words",
    "words words words words",
    "words words";

    is-deeply @para, @p1;
}

# test 3
{
    @para = write-paragraph(@text, :max-line-length(20));

    @p1 =
    "words words words",
    "words words words",
    "words words words",
    "words";

    is-deeply @para, @p1;
}

# test 4
{
    @para = write-paragraph(@text, :max-line-length(38), :pre-text('topic:  '));

    @p1 =
    "topic:  words words words words words",
    "        words words words words words";

    is-deeply @para, @p1;
}

# test 5
{
    @para = write-paragraph(@text, :max-line-length(30), :first-line-indent(3));

    @p1 =
    "   words words words words",
    "words words words words words",
    "words";

    is-deeply @para, @p1;
}

# test 6
{
    @para = write-paragraph(@text, :max-line-length(33), :first-line-indent(3),
		    :para-indent(5));

    @p1 =
    "   words words words words words",
    "     words words words words",
    "     words";

    is-deeply @para, @p1;
}

# test 7
{
    @para = write-paragraph(@text, :max-line-length(33), :first-line-indent(5),
			    :para-indent(3));

    @p1 =
    "     words words words words",
    "   words words words words words",
    "   words";

    is-deeply @para, @p1;
}

# test 8
{
    @para = write-paragraph(@text, :pre-text('text: '), :max-line-length(39),
			    :first-line-indent(5), :para-indent(3));

    @p1 =
    "text:      words words words words",
    "         words words words words words",
    "         words";

    is-deeply @para, @p1;
}

#============================================================================================
# the file output version

# test 9 (compare with 1)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(30));
    $fh.close;

    @p1 =
    "words words words words words",
    "words words words words words";

    is-deeply [slurp($f).lines], @p1;
}

# test 10 (compare with 2)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(24));
    $fh.close;

    @p1 =
    "words words words words",
    "words words words words",
    "words words";

    is-deeply [slurp($f).lines], @p1;
}

# test 11 (compare with 3)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(20));
    $fh.close;

    @p1 =
    "words words words",
    "words words words",
    "words words words",
    "words";

    is-deeply [slurp($f).lines], @p1;
}

# test 12 (compare with 4)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(38), :pre-text('topic:  '));
    $fh.close;

    @p1 =
    "topic:  words words words words words",
    "        words words words words words";

    is-deeply [slurp($f).lines], @p1;
}

# test 13 (compare with 5)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(30), :first-line-indent(3));
    $fh.close;

    @p1 =
    "   words words words words",
    "words words words words words",
    "words";

    is-deeply [slurp($f).lines], @p1;
}

# test 14 (compare with 6)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(33), :first-line-indent(3),
		    :para-indent(5));
    $fh.close;

    @p1 =
    "   words words words words words",
    "     words words words words",
    "     words";

    is-deeply [slurp($f).lines], @p1;
}

# test 15 (compare with 7)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :max-line-length(33), :first-line-indent(5),
		    :para-indent(3));
    $fh.close;

    @p1 =
    "     words words words words",
    "   words words words words words",
    "   words";

    is-deeply [slurp($f).lines], @p1;
}

# test 16 (compare with 3)
{
    my $fh = open $f, :w;
    write-paragraph($fh, @text, :pre-text('text: '), :max-line-length(39),
		    :first-line-indent(5), :para-indent(3));
    $fh.close;

    @p1 =
    "text:      words words words words",
    "         words words words words words",
    "         words";

    is-deeply [slurp($f).lines], @p1;
}

# test some corner cases ==================================
#                         1         2         1
my Str @text2 = '123456789012345678901234567890';   # 30 chars
my Str @text3 = '12345678901234567890123456789012'; # 32 chars
# test 17
{
    @para = write-paragraph(@text2, :max-line-length(30));

    @p1 =
    "123456789012345678901234567890";

    is-deeply @para, @p1, "line at maxlength";
}

# a bogus check for debugging:
#is 1, 1;

=begin pod
# test 18
{
    dies-ok { @para = write-paragraph(@text2, :max-line-length(30), :pre-text('def: ')) }, "line reported too long";
}
=end pod

# test 19
{
    dies-ok { @para = write-paragraph(@text3, :max-line-length(30)) }, "line reported too long";
}

# test 20 (compare with 17)
{
    my $fh = open $f, :w;
    #dies-ok {write-paragraph($fh, @text2, :max-line-length(30)) }, "line reported too long";
    write-paragraph($fh, @text2, :max-line-length(30));
    $fh.close;

    @p1 =
    "123456789012345678901234567890";

    is-deeply [slurp($f).lines], @p1;
}

#============================================================================================
unlink $f;
