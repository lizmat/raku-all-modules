
Text::Fortune
=============

> One of the miseries of life is that everybody names things a little bit wrong.
>   —- Richard P. Feynman

Text::Fortune is the bare beginnings of a Perl6 module for dealing with
`fortune(6)` and `strfile(1)` type files.

The inteface is totally up in the air at the moment....

It's workable, but very ugly.

    use Text::Fortune;
    
    # a strfile(1) equivalent
    sub strfile ($fortunefile) {
      my $index = Text::Fortune::Index.new.load-fortune($fortunefile);
      ($fortunefile ~ '.dat').IO.open(:w).write($index.Buf);
    }
    
    # load existing '.dat' file
    my $index = Text::Fortune::Index.new.load-dat($datfile);
    print qq:to<END>;
    there are {$index.count} fortunes delimited by {$index.delimiter}
    the longest is {$index.longest} characters
    the shortest is {$index.shortest}
    they are {$.rotated ?? '' !! 'not'} in rot13 (obscene)
    the offset of the last quote is {$index.offset-at($index.count - 1)}
    and it is {$index.bytelength-of($index.count - 1)} *bytes*
    END

    # bare fortune(6)
    my $fortune = Text::Fortune::File.new( path => '/usr/share/games/fortunes/perl' );
    say $fortune.get-fortune((0..^$fortune.count).pick)  # aka .random()

    ---
    Tcl tends to get ported to weird places like routers.
                    -- Larry Wall in <199710071721.KAA19014@wall.org>
    ---

    # handles offensive (rot13) fortunes
    my $fortune = Text::Fortune::File.new( path => '/usr/share/games/fortunes/off/religion' );
    say $fortune.get-fortune((0..^$fortune.count).pick)

    ---
    Imagine there's no heaven... it's easy if you try.
                    -- John Lennon, "Imagine"
    ---


Things are certain to change.

