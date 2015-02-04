use Perl6::Format;

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
 %options<indentsize> = 2;

while ($i < @*ARGS)
{
 if (@*ARGS[$i] eq "-h")
 {
   note 
"Perl6 formatter
-h  help
-is size indent size
 standard input input file
 standard output output file
";
  exit 1;
 }
elsif (@*ARGS[$i] eq "-is")
{
  %options<indentsize> = getnextargument($i++,"indentation size");
}
else
{
  note "unknown argument "~  @*ARGS[$i];
  exit 1;
}
$i++;
}

use Perl6::Format;
my $f = Perl6::Format.new();

my $content = $*IN.slurp;

print $f.format(%options,$content);