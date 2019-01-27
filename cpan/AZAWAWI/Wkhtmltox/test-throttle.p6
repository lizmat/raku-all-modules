use v6.c;

# Standard output is now unbuffered
$*OUT.out-buffer = False;

# Constants
constant COUNT = 100;

my $num-of-workers = $*KERNEL.cpu-cores * 4;

say "Number of PDF files = {COUNT}";
say "Number of workers   = $num-of-workers";

# Make sure output folder is there
"output".IO.mkdir;

# Generate PDFs with throttling
my $t0 = now;
my @results = [^COUNT].race(:batch(1), :degree($num-of-workers)).map({
	my $output-filename = "output/test-$_.pdf";
	$output-filename.IO.unlink;
	my $output = qq:x/wkhtmltopdf --quiet input.html $output-filename/;
	my $blob = $output-filename.IO.slurp(:bin);
	my %result = :name($output-filename), :blob($blob);
}).list;

say "It took ", (now - $t0), " to generate {COUNT} PDF files";
say @results.elems;
