# Grammar::Profiler::Simple
This module provides a simple profiler for Perl 6 gramamrs. To enable
profiling simply add

    use Grammar::Profiler::Simple;

to your code. Any grammar in the lexical scope of the use statement
will automatically have profiling information collected when the
grammar is used.

This module exports two subroutines, each with 3 variants:

### `reset-timing()`

Reset all time information collected since the start of the program or since the last call to
`reset-timing()`

### `reset-timing($grammar)`

Reset all time information only for the specified grammar.

### `reset-timing($grammar, $rule)`

Reset all time information only for the specified rule within the specified grammar.

### `get-timing()`

Retrieve the timing information collected so far or since the last call
to `reset-timing`. Returned as a mult-level hash with the first level
indexed by the name of the grammar and the second level indexed by the
name of the rule within the grammar.

### `get-timing($grammar)`

Retrieve the timing information collected for a particular grammar.

### `get-timing($grammar, $rule)`

Retrieve the timing information collected for a particular rule within a particular grammar.

## Timing information

There are 2 bits of timing information collected:  the number of times each rule was called
and the cumulative time that was spent executing each rule.  For example

say "MyRule was called {get-timing('MyGrammar','MyRule')<calls>} times";
say "The total time executing MyRule was {get-timing('MyGrammar','MyRule')<time>} seconds";


