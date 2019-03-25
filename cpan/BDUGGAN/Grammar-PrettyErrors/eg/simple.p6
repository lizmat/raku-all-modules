use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    <hello>
    <world>
  }
  token hello { hi }
  token world { there }
}

say so G.new.parse('hi there');
say so G.new.parse('hi here');
