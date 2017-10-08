use v6;
use Test;
use Algorithm::Kruskal;

our sub do-it($input-path) {
    my $fh = open $input-path, :r;
    my $header = $fh.get;
    my ($vertex-size, $num-of-edges, $weight) = $header.split(/\s/);
    my $kruskal = Algorithm::Kruskal.new(vertex-size => $vertex-size);
    for $fh.lines -> $line {
	my ($from, $to, $weight) = $line.split(/\s/);
	$kruskal.add-edge($from.Int, $to.Int, $weight.Real);
    }
    
    my %forest = $kruskal.compute-minimal-spanning-tree();
    is %forest<weight>, $weight;
}

{
    do-it("./t/in/01.txt");
}

{
    do-it("./t/in/02.txt");
}

{
    do-it("./t/in/03.txt");
}

{
    do-it("./t/in/04.txt");
}

done-testing;
