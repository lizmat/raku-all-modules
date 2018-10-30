unit module Diviner;

use File::Find;

grammar Divinants {

  regex Symbol {
    <:Letter>
    [
    |<[ ' - ]><?before <:Letter>>
    |<:Letter + :Number + [ _ : ]>
    ]*
    [ <?after ':'> <-[ { ( ]>+ <?before \s* <[ { ( ]> > ]?
  }

  regex PackedSymbol {
    <Symbol>['::'<Symbol>]*
  }

  token TOP { [ <line> <nl>? ]+ }

  token line {
    ^^
    [
    | <module>
    | <class>
    | <role>
    | <grammar>
    | <named-re>
    | <sub>
    | <method>
    | <variable>
    ]?
    <gibberish>?
    $$
  }

  token nl { \n }

  token gibberish { <-[\n]>+ }

  token module {
    \s* [unit \s+]? module \s+ <PackedSymbol>
  }

  token class {
    \s* [unit \s+]? class \s+ <PackedSymbol>
  }

  token grammar {
    \s* grammar \s+ <PackedSymbol>
  }

  token role {
    \s* role \s+ <PackedSymbol>
  }

  token named-re {
    \s* (regex|rule|token) \s+ <PackedSymbol>
  }

  token sub {
    \s* [multi \s+]? sub \s+ <Symbol>
  }

  token method {
    \s* [multi \s+]? method \s+ <Symbol>
  }

  token variable {
    \s* [my|our|has|state|temp|let] \s+ (<[ $ @ % & ]>)<Symbol>
  }
}

class Completion {
  has $.file;
  has $.name;
  has $.kind;
  has $.line;
  submethod gist { $!name.say }
}

class Divinations {

  has $.begin;
  has $.file;
  has $!ln = 1;
  has Bool $!internal;

  submethod BUILD(:$!begin, :$!file, :$!ln, :$!internal = False) {}

  method nl($/ is copy) { $!ln++ }

  method module($/ is copy) {
    my $should-take = $!begin.so ?? $<PackedSymbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<PackedSymbol>.Str,
        kind => 'module',
        line => $!ln
      )
    }
  }

  method class($/ is copy) {
    my $should-take = $!begin.so ?? $<PackedSymbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<PackedSymbol>.Str,
        kind => 'class',
        line => $!ln
      )
    }
  }

  method grammar($/ is copy) {
    my $should-take = $!begin.so ?? $<PackedSymbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<PackedSymbol>.Str,
        kind => 'grammar',
        line => $!ln
      )
    }
  }

  method role($/ is copy) {
    my $should-take = $!begin.so ?? $<PackedSymbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<PackedSymbol>.Str,
        kind => 'role',
        line => $!ln
      )
    }
  }

  method named-re($/ is copy) {
    my $should-take = $!begin.so ?? $<PackedSymbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<PackedSymbol>.Str,
        kind => $0.Str,
        line => $!ln
      )
    }
  }

  method sub($/ is copy) {
    my $should-take = $!begin.so ?? $<Symbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<Symbol>.Str,
        kind => 'sub',
        line => $!ln
      )
    }
  }

  method method($/ is copy) {
    my $should-take = $!begin.so ?? $<Symbol>.Str.starts-with: $!begin !! True;
    if $should-take {
      take Completion.new(
        file => $!file,
        name => $<Symbol>.Str,
        kind => 'method',
        line => $!ln
      )
    }
  }

  method variable($/ is copy) {
    my $should-take = do with $!begin {
      ($0 ~ $<Symbol>.Str).starts-with: $_ } else { $!internal }
    if $should-take {
      take Completion.new(
        file => $!file,
        name => ($0 ~ $<Symbol>.Str),
        kind => 'variable',
        line => $!ln
      )
    }
  }

}

=begin old
sub run {

  multi sub infix:<cmp>(Completion:D $a, Completion:D $b) {
    my $name1 = $a.name.substr(1) if $a.name.comb[0] ~~ /<[$@%&]>/;
    my $name2 = $b.name.substr(1) if $b.name.comb[0] ~~ /<[$@%&]>/;
    ($name1 // $a.name).lc cmp ($name2 // $b.name).lc;
  }

  for @completions.sort({ $^a cmp $^b }) { .say }

}
=end old

sub completions (Str $begin, @files, :$external = False) is export {
  my Completion @completions;
  for @files -> $io {
    my $file = $io.absolute.Str;
    my $text = slurp $file;
    @completions.append: gather {
      Divinants.parse($text, :actions(Divinations.new(
        :$file,
        :$begin,
        :internal(!$external)
      )));
    }
  }
  for @completions { .perl.say }
}

sub tags-json (@files, :$all) is export {
  use JSON::Marshal;

  my Completion @completions;

  for @files -> $io {
    my $file = $io.absolute.Str;
    my $text = slurp $file;
    @completions.append: gather {
      Divinants.parse($text, :actions(Divinations.new( :$file, :internal($all) )));
    }
  }

  "[\n\t" ~ @completions.map({ marshal($_) }).join(",\n\t") ~ "\n]"
}

sub tags-ctag (@files, :$all) is export {

  my Completion @completions;

  for @files -> $io {
    my $file = $io.absolute.Str;
    my $text = slurp $file;
    @completions.append: gather {
      Divinants.parse($text, :actions(Divinations.new( :$file, :internal($all) )));
    }
  }

  gather for @completions {
    take "{$_.name}\t{$_.file}\t{$_.line}\t{$_.kind}";
  }
}

our $foo = 'woah!';
