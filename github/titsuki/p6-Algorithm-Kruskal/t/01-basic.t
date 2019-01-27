use v6;
use Test;
use Algorithm::Kruskal;

our sub do-it($input-path) {
    my $fh = open $input-path, :r;
    my $header = $fh.get;
    my @header-elems = $header.words;
    my ($vertex-size, $num-of-edges) = @header-elems[0,1]>>.Int;
    my $weight = @header-elems[2].Num;
    my $kruskal = Algorithm::Kruskal.new(vertex-size => $vertex-size);
    for $fh.lines -> $line {
        my @line-elems = $line.words;
        my ($from, $to) = @line-elems[0,1]>>.Int;
        my $weight = @line-elems[2].Num;
        $kruskal.add-edge($from, $to, $weight);
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
