
use v6;

use Data::Dump;

my $source = q:to/END/;
    class Foo {
      sub foo1 { }
      sub foo2 { }
      method foo3 { }  
    }
  END
  


=begin doc
=end doc

use Perl6::Parser;
my $parser = Perl6::Parser.new;
my $tree =  $parser.to-tree($source);
say $tree.perl;

sub dump-stuff($element) {
  state @results;
 #say $element.^name ~ " => " ~ ($element.^can('content') ?? $element.content.perl !! "N/A") ~", from = " ~ ($element.^can('from') ?? $element.from !! 'N/A');

  my $type = Any;
  if $element.^can('child') {
    for $element.child -> $child {
       #say $child.^name ~ " => " ~ ($child.^can('content') ?? $child.content.perl !! "N/A") ~", from = " ~ ($child.^can('from') ?? $child.from !! 'N/A');

      if $child.^name eq 'Perl6::SubroutineDeclaration'  {
        $type = 'sub';
      }
      if $child.^name eq 'Perl6::ClassDeclaration'  {
        $type = 'class';
      }
      if $child.^name eq 'Perl6::Bareword'  {
        # && $element.^name eq 'Perl6::SubroutineDeclaration'
        if $type.defined {
          @results.push({
            type => $type,
            name => $child.content,
            from => $child.from,
            to   => $child.to,
          });
          $type = Any;
        }
      }

      dump-stuff($child);
    }
    @results;
  }
}
my @results = dump-stuff($tree);
#say @results;
