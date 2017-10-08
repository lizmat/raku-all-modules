use v6;
unit class Search::Dict:ver<0.2>:auth<github:zengargoyle>;

=begin pod

=head1 NAME

Search::Dict - a fast binary search of dictionary like files

=head1 SYNOPSIS

  use Search::Dict;

  my &lookup = search-dict('/usr/share/dict/words');

  given lookup('existing-word') -> $w {
    +$w;  # seek offset in dict
    ?$w;  # True
    ~$w;  # 'existing-word'
  }
  given lookup('non-existing-word') -> $w {
    +$w;  # seek offset after where non-existing-word would be
    ?$w;  # False
    ~$w;  # word after where non-existing-word would be
    # or
    $w.match.defined # False  - after last word in dict
  }

=head1 DESCRIPTION

Search::Dict is a fast binary search of dictionary like files (e.g. F</usr/share/dict/words>).  A dictionary file is one where:

one entry per line

lines are sorted

=end pod

my class R {
  has Str $.match handles <Str>;
  has Bool $.found handles <Bool>;
  has Int $.pos handles <Numeric Int>;
  method gist { qq:to[END].chomp;
    (:found($.found) :pos($.pos) :match($.match))
    END
  }
}

sub search-dict( $filename, :$block-size = 128 ) is export {
  my $fh = $filename.IO.open;
  my $size = $filename.IO.s // do { .seek(0,SeekFromEnd); my $s = .tell; .seek(0,SeekFromBeginning); $s }($fh);
  my $min = 0;
  my $max = Int($size / $block-size);  # XXX: blksize?

  sub look($fh, $key, $min is copy, $max is copy) {
    while $max - $min > 1 {
      state $mid;
      $mid = Int(($max + $min) / 2);
      $fh.seek: $mid * $block-size, SeekFromBeginning;
      $fh.get if $mid;
      given $fh.get {
        when !*.defined { last }
        when * lt $key { $min = $mid }
        default { $max = $mid }
      }
    }
    $fh.seek: $min * $block-size, SeekFromBeginning;
    $fh.get if $min;

    my Bool $found = False;
    my Int $pos;
    my Str $match;

    loop {
      $pos = $fh.tell;
      given $fh.get {
        when !.defined { return R.new( :$found,      :$pos, :match(Str) ) }
        when $key      { return R.new( :found(True), :$pos, :match($_) ) }
        when * gt $key { return R.new( :$found,      :$pos, :match($_) ) }
      }
    }
    fail "can not happen!";
  }

  return sub (Str $string) {
    look($fh, $string, $min, $max)
  }
}


=begin pod

=head1 AUTHOR

zengargoyle <zengargoyle@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
