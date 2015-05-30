unit role ForeignGrammar;
method foreign-rule ($regex_name, $class) {
    my $cursor = $class.'!cursor_init'(self.orig(), :p(self.pos()));
    my $ret = $cursor."$regex_name"();
    self.MATCH.make: $ret.MATCH.ast;
    $ret;
}
