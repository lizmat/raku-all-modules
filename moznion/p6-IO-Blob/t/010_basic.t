use v6;

use Test;

use IO::Blob;

constant TEXT = "line1\nline2\nline3\nline4";

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    is $io.tell(), 0;
    is $io.ins(), 1;
    is $io.eof(), False;

    is $io.get(), "line1\n", 'should get the first line';
    is $io.tell(), 6;
    is $io.ins(), 2;

    is $io.get(), "line2\n", 'should get the second line';
    is $io.tell(), 12;
    is $io.ins(), 3;

    is $io.get(), "line3\n", 'should get the third line';
    is $io.tell(), 18;
    is $io.ins(), 4;

    is $io.get(), "line4", 'should get the fourth line';
    is $io.tell(), 23;
    is $io.ins(), 4;

    is $io.get(), "", 'should get the empty';
    is $io.tell(), 23;
    is $io.ins(), 4;

    is $io.eof(), True;
}, 'Test for get()';

subtest {
    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.tell(), 0;
        is $io.ins(), 1;
        is $io.eof(), False;

        my @expected = ["line1\n", "line2\n", "line3\n", "line4"];
        is-deeply $io.lines(), @expected;
        is $io.tell(), 23;
        is $io.ins(), 4;
        is $io.eof(), True;

        is $io.lines(), ();
    }, 'lines() with infinity';

    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.tell(), 0;
        is $io.ins(), 1;
        is $io.eof(), False;

        my @expected = ["line1\n", "line2\n"];
        is-deeply $io.lines(2), @expected;
        is $io.tell(), 12;
        is $io.ins(), 3;
        is $io.eof(), False;
    }, 'lines() with limited';
}, 'Test for lines()';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    is $io.tell(), 0;
    is $io.ins(), 1;
    is $io.eof(), False;

    is $io.getc(), 'l';
    is $io.tell(), 1;
    is $io.ins(), 1;

    for 1..3 {
        $io.getc();
    }
    is $io.getc(), '1';
    is $io.tell(), 5;
    is $io.ins(), 1;

    is $io.getc(), "\n";
    is $io.tell(), 6;
    is $io.ins(), 2;

    $io.lines();

    is $io.getc, "";
    is $io.tell(), 23;
    is $io.ins(), 4;

    is $io.eof(), True;
    is $io.perl, 'IO::Blob.new(data => utf8.new(108, 105, 110, 101, 49, 10, 108, 105, 110, 101, 50, 10, 108, 105, 110, 101, 51, 10, 108, 105, 110, 101, 52))';
    is $io.gist, 'IO::Blob(opened, at ins 4 / pos 23)';
}, 'Test for getc()';

subtest {
    constant TEXT = "word1 word2\tword3\nword4";

    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    is $io.tell(), 0;
    is $io.ins(), 1;
    is $io.eof(), False;

    is $io.word(), "word1 ";
    is $io.tell(), 6;
    is $io.ins(), 1;

    is $io.word(), "word2\t";
    is $io.tell(), 12;
    is $io.ins(), 1;

    is $io.word(), "word3\n";
    is $io.tell(), 18;
    is $io.ins(), 2;

    is $io.word(), "word4";
    is $io.tell(), 23;
    is $io.ins(), 2;

    is $io.word(), "";
}, 'Test for word()';

subtest {
    constant TEXT = "word1 word2\tword3\nword4";

    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.tell(), 0;
        is $io.ins(), 1;
        is $io.eof(), False;

        my @expected = ["word1 ", "word2\t", "word3\n", "word4"];
        is-deeply $io.words(), @expected;
        is $io.tell(), 23;
        is $io.ins(), 2;
        is $io.eof(), True;

        is $io.words(), ();
    }, 'words() with infinity';

    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.tell(), 0;
        is $io.ins(), 1;
        is $io.eof(), False;

        my @expected = ["word1 ", "word2\t", "word3\n"];
        is-deeply $io.words(3), @expected;
        is $io.tell(), 18;
        is $io.ins(), 2;
        is $io.eof(), False;
    }, 'words() with limit';
}, 'Test for words()';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    is $io.read(TEXT.chars), TEXT.encode;
    is $io.read(TEXT.chars), "".encode;

    $io.seek(0, 0);
    is $io.read(TEXT.chars), TEXT.encode;

    $io.seek(0, 0);
    $io.seek(6, 1);
    is $io.read(10), "line2\nline".encode;

    is $io.eof(), False;
    $io.seek(0, 2);
    is $io.eof(), True;
}, 'Test for seek() and read()';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    $io.print('line5', 'line6');
    is $io.tell(), 33;
    # is $io.ins(), 5;
    is $io.eof(), True;

    $io.seek(0, 0);
    is $io.read(TEXT.chars + 12), "line1\nline2\nline3\nline4line5line6".encode;
    is $io.data(), "line1\nline2\nline3\nline4line5line6".encode;
}, 'Test for print() and seek()';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);

    $io.write('line5'.encode);
    is $io.tell(), 28;
    # is $io.ins(), 5;
    is $io.eof(), True;

    $io.seek(0, 0);
    is $io.read(TEXT.chars + 12), "line1\nline2\nline3\nline4line5".encode;
}, 'Test for write() and seek()';

subtest {
    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.slurp-rest(bin => True), "line1\nline2\nline3\nline4".encode;
        is $io.slurp-rest(bin => True), Buf.new();

        $io.seek(6, 0);
        is $io.slurp-rest(bin => True), "line2\nline3\nline4".encode;
    }, 'bin';

    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.slurp-rest(enc => 'utf8'), "line1\nline2\nline3\nline4";
        is $io.slurp-rest(enc => 'utf8'), "";

        $io.seek(6, 0);
        is $io.slurp-rest(enc => 'utf8'), "line2\nline3\nline4";
    }, 'with encode';

    subtest {
        my IO::Blob $io = IO::Blob.new(TEXT.encode);

        is $io.slurp-rest(), "line1\nline2\nline3\nline4";
        is $io.slurp-rest(), "";

        $io.seek(6, 0);
        is $io.slurp-rest(), "line2\nline3\nline4";
    }, 'with out encode';
}, 'Test for slurp-rest';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);
    is $io.is-closed(), False;

    $io.close();

    is $io.is-closed(), True;
    is $io.get(), "".encode;
    is $io.getc(), "".encode;
    is $io.lines(), ();
    is $io.word(), "".encode;
    is $io.words(), ();
    is $io.read(100), "".encode;
    is $io.slurp-rest(bin => True), "".encode;
    is $io.slurp-rest(enc => 'utf8'), "";
    is $io.perl, 'IO::Blob.new(data => Blob)';
    is $io.gist, 'IO::Blob(closed)';
}, 'Test for close()';

subtest {
    my IO::Blob $io = IO::Blob.new(TEXT.encode);
    $io.nl = Nil;
    is $io.get(), TEXT.encode;
}, 'Test for nl';

subtest {
    {
        my IO::Blob $io = IO::Blob.new(TEXT);
        is $io.slurp-rest, TEXT;
    }
    {
        my IO::Blob $io = IO::Blob.open(TEXT);
        is $io.slurp-rest, TEXT;
    }
}, 'Test for constructor for string';

done-testing;

