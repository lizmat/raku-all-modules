use v6.c;
unit class Text::MiscUtils:ver<0.0.3>;


=begin pod

=head1 NAME

Text::MiscUtils - A bag of small text processing tricks

=head1 SYNOPSIS

  # English language utilities
  use Text::MiscUtils::English;

  say ordinal(23);               # '23rd'

  my $n = 2;                     # $n = 1 would give correct singular words
  say _s($n, 'geese', 'goose');  # 'geese'
  say "fox{_s($n, 'es')}";       # 'foxes'
  say 'frog' ~ _s($n);           # 'frogs'


  # Text layout utilities
  use Text::MiscUtils::Layout;

  evenly-spaced(12, '1', '22', '55555');  # '1  22  55555'
  text-wrap(6, 'a bc def ghij');          # ['a bc', 'def', 'ghij']

  text-columns(5, "12\n34\n", "abc\ndefg\nhi");
  # 12     abc  
  # 34     defg 
  #        hi   

  text-columns(4, "12\n34\n", "abc\ndefg\nhi", :sep<|>);
  # 12  |abc 
  # 34  |defg
  #     |hi  

  # Note trailing spaces to pad out to width in text-columns() example output

=head1 DESCRIPTION

Text::MiscUtils is a collection of small text processing routines, none of
which are complex enough to merit their own distribution, but in aggregate
add up to a bunch of finicky boilerplate no one should have to write yet again.

They get regular use by my other modules/programs, but are by no means perfect.
For example, while the utilities in Text::MiscUtils::Layout should work fine
with embedded ANSI color codes (ignoring them for purposes of calculating space
used), they don't currently handle Unicode full width characters properly,
treating them as width 1 instead of width 2.

=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2016-2017 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
