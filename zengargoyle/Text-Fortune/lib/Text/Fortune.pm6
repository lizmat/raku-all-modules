
use v6;

=begin pod

=head1 NAME

Text::Fortune - print a random adage, fortune(6), strfile(1)

=head1 SYNOPSIS

  use Text::Fortune;

  # Random fortune from 'fortunefile' & 'fortunefile.dat' -- fortune(6)
  my $fortune = Text::Fortune::File.new( path => $fortunefile );
  say $fortune.random;

  # Generate 'fortunefile.dat' from 'fortunefile' -- strfile(1)
  my $datfile = $fortunefile ~ '.dat';
  $datafile.IO.open(:w).write(
    Text::Fortune::Index.new.load-fortune( $fortunefile.IO.path )
  );

=head1 DESCRIPTION

Text::Fortune is a minimal implementation for implementing the fortune(6)
and strfile(1) progams, with functions for generating a 'fortunes.dat' file
from a 'fortunes' file (strfile(1)) and for retrieving a random fortune
(fortune(6)).

=head1 COPYRIGHT AND LICENSE

Copyright 2015 zengargoyle <zengargoyle@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

unit module Text::Fortune:ver<0.03>;

my class X::Index::NotFound is Exception {
  method message() {
    "not found.";
  }
}

my class X::Index::OutOfBounds is Exception {
  method message() {
    "not found.";
  }
}

class Index {
  has Int $.version = 2;
  has Int $.count = 0;
  has Int $.longest = 0;
  has Int $.shortest = 0xFFFFFFFF;
  has Bool $.rotated = False;
  has Str $.delimiter;
  has Int @!offset;

  submethod BUILD ( Bool :$!rotated, Str :$!delimiter = '%' ) {
    # TODO - check delimiter length and ASCII-ness
  }

  # 'rotated' is bit 3 (0x4) in the .dat file header flags field
  method flags-to-int (--> Int) { $!rotated ?? 0x4 !! 0 }
  method flags-from-int( Int $flags --> Bool ) { $!rotated = so $flags +& 0x4 }

  method offset-at ( Int $at --> Int ) {
    @!offset[$at];
  }

  # NOTE - fortune(6) has no concept of multi-byte encodings so
  # this function has limited usefulness.  it's completely useless
  # if either 'ordered' or 'random' flags are set, which is part of
  # why we're not supporting them.  plus, ordered and random are
  # rarely if ever seen in a .dat file for fortunes.
  #
  method bytelength-of ( Int $at --> Int ) {
    if $at >= $!count {
      X::Index::OutOfBounds.new.throw;
    }
    $.offset-at( $at+1 ) - $.offset-at( $at ) - 2;
  }

  method load-fortune ($fortunefile) {

    X::Index::NotFound.new.throw unless
      $fortunefile.IO ~~ :e & :!d & :r;

    my $ff = $fortunefile.IO.open :r :!chomp;

    my $stop = $!delimiter ~ "\n";

    # TODO - probably need to handle "%\n%\n" empty quotes, i think
    # strffile(1) squashes them.
    while ! $ff.eof {
      my $pos = $ff.tell;
      my $len;
      while $ff.get -> $line {
        last if $line eq $stop;
        $len += $line.chars
      }
      if $len {
        $!longest max= $len;
        $!shortest min= $len;
        $!count++;
        @!offset.push: $pos;
      }
    }

    # NOTE - @offset.elems == $count + 1
    # strfile(1) adds an offset for the end of the file, probably to
    # support calculating quote length from @offset[$n+1] - @offset[$n] - 2
    # logic.
    @!offset.push: $ff.tell;

    self;
  }

  method load-dat ($datfile) {

    X::Index::NotFound.new.throw unless
      $datfile.IO ~~ :e & :!d & :r;

    if $datfile.IO.open :r -> $dat {
      $!version = $dat.read(4).unpack('N');
      $!count = $dat.read(4).unpack('N');
      $!longest = $dat.read(4).unpack('N');
      $!shortest = $dat.read(4).unpack('N');

      $.flags-from-int( $dat.read(4).unpack('N') );

      $!delimiter = $dat.read(1).unpack('C').chr;

      $dat.seek(24,0);
      loop (my $i = 0; $i <= $!count; $i++) {
        @!offset.push: $dat.read(4).unpack('N');
      }
    }
    else {
      # XXX - throw something...
    }

    self;
  }

  method Buf {
    my Buf $b;
    $b = pack('N', $!version);
    $b ~= pack('N', $!count);
    $b ~= pack('N', $!longest);
    $b ~= pack('N', $!shortest);

    $b ~= pack('N', $.flags-to-int);
    $b ~= pack('CCCC', $!delimiter.ord, 0, 0, 0);

    if $!count == 0 {
        $b ~= pack('N', 0);
    }
    else {
      for @!offset -> $o {
        $b ~= pack('N', $o);
      }
    }

    $b;
  }

}

class File {
  has IO::Handle $!handle;
  has Text::Fortune::Index $!index handles <version count longest shortest delimiter>;
  has Bool $.rotated;  # need our own to override in case .dat is wrong.

  submethod BUILD (
    :$path as IO,
    :$index?,
    :$datpath = $path ~ '.dat',
    :$rotated,
  ) {
    unless $path.IO ~~ :e & :!d & :r {
      X::Index::NotFound.new.throw;
    }
    $!handle = $path.IO.open :r :!chomp;

    if $datpath.IO ~~ :e & :!d & :r {
      $!index = Text::Fortune::Index.new.load-dat( $datpath );
    }
    else {
      $!index = Text::Fortune::Index.new.load-fortune( $path );
    }

    $!rotated = $!index.rotated;
    $!rotated = $rotated if $rotated.defined;
  }

  method get-from-offset ( Int $o ) {
    my $stop = $!index.delimiter ~ "\n";
    $!handle.seek: $o, 0;
    my Str $content;
    while $!handle.get -> $line {
      last if $line eq $stop;
      $content ~= $line;
    }
    $content;
  }

  method random { $.get-fortune( $.count.rand.Int ) }

  method get-fortune ( Int $n ) {
    my $fortune = $.get-from-offset( $!index.offset-at( $n ) );
    if $!rotated {
      $fortune .= trans( 'n..za..mN..ZA..M' => 'a..zA..Z' );
    }
    $fortune;
  }

}
