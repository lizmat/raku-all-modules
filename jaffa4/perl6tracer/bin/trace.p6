use Perl6::Tracer;

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


while ($i < @*ARGS)
{
 if (@*ARGS[$i] eq "-h")
 {
   note 
"Perl6 tracer
-h  help
 standard input input file
 standard output output file
";
  exit 1;
 }
else
{
  note "unknown argument "~  @*ARGS[$i];
  exit 1;
}
$i++;
}

my $f = Perl6::Tracer.new();

my $content = $*IN.slurp;

print $f.trace(%options,$content);