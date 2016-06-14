# p6-Algorithm-Tarjan

A perl6 implementation of Tarjan's algorithm for finding strongly connected components in a directed graph. 

More information can be found at wikipedia.org/wiki/Tarjan's_strongly_connected_components_algorithm.

If there is a cycle, then it will be within a strongly connected component. This implies that the absence of strongly connected components (other than a node with itself) means there are no cycles. It is possible there may be no cycles, but a strongly connected component may still exist (if I have interpreted the theory correctly). I was interested in the absence of cycles.

```
use Algorithm::Tarjan;

my Algorithm::Tarjan $a .= new();

my %h;
# code to fill %h node->[successor nodes]

$a.init(%h);
say 'There are ' ~ $a.find-cycles() ~ ' cycle(s) in the input graph';
```
If there is a need for the sets of strongly connected components, they can be retrieved from $a.strongly-connected (an array of node names).

