use Rakudo::Perl6::Tracer;

sub getnextargument($index, $explanation)
{
  if ($index+1>=@*ARGS.elems)
  {
    note "$explanation is missing after "~@*ARGS[$index];
    exit 1;
  }
  return @*ARGS[$index+1];
}

my $i = 0;
my %options;
%options<showline> = False;
%options<compiletime> = False;

while ($i < @*ARGS)
{
 given (@*ARGS[$i]) {
  when "-h"
 {
   note 
"Perl6 tracer
-h  help
-sl show whole line when tracing
=c  trace compilation
 standard input input file
 standard output output file
";
  exit 1;
 }
 when "-sl"
{
  %options<showline> = True;
}
 when "-c"
{
  %options<compiletime> = True;

}
default
{
  note "unknown argument "~  @*ARGS[$i];
  exit 1;
}
 }
$i++;
}

my $f = Rakudo::Perl6::Tracer.new();

my $content = $*IN.slurp-rest;

print $f.trace(%options,$content);