unit module HTML::MyHTML::State;

#| A non-global store of pointers to the raw parser and tree
my module State is export {
  our $parser;
  our $tree;
}
