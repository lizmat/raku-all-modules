use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    <hello>
    <world>
  }
  token hello { hi }
  token world { there }
}

G.new.parse('hi here') orelse say "failed at line {.exception.line}";
