Lingua::EN::Sentence - Perl6 port
========================

[![Build Status](https://secure.travis-ci.org/dginev/perl6-Lingua-EN-Sentence.png?branch=master)](http://travis-ci.org/dginev/perl6-Lingua-EN-Sentence)

Perl6 port of the Lingua::EN::Sentence CPAN module

The Port is complete, you're welcome to use the library in production code.

Bug reports and feature requests are welcome in the Github Issue tracker.
 
 Don't miss on using the fresh Perl6 syntax:
 ```perl6
  use Lingua::EN::Sentence;
  my Str $text;
  $text = slurp 'some_text_file.txt';
  my @sentences = $text.sentences;
  ```
