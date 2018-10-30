use v6;
use Gumbo::Binding;
use NativeCall::TypeDiag;
my @headers = <gumbo.h>;
my @libs = <-lgumbo>;
my @fun;

my %typ;
# Construct the type from the exported stuff
for Gumbo::Binding::EXPORT::DEFAULT::.keys -> $export {
  if ::($export).REPR eq 'CStruct' {
    #convert foo_bar_s to FooBar
    my $cname = $export.subst(/_s$/, '');
    my @t = $cname.split('_').map: {.tc};
    %typ{@t.join('')} = ::($export);
  }
  if ::($export).does(Callable) and ::($export).^roles.perl ~~ /NativeCall/ {
     @fun.push(::($export));
  }
}

say "Checking Structs";
diag-cstructs(:cheaders(@headers), :types(%typ), :clibs(@libs));

my $t = ::("gumbo_node_s");
diag-struct("GumboNode", $t, :cheaders(@headers), :clibs(@libs));
say "Checking functions declaration";
diag-functions(:functions(@fun));
