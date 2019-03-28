use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    <hello>
    <world>
  }
  token hello { hi }
  token world { there }
}

my $g = G.new(:quiet);
$g.parse('hi here');
say so $g.error.message ~~ /'hi'/;
