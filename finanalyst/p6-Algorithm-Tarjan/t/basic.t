use v6;
use Test;

use Algorithm::Tarjan;

my Algorithm::Tarjan $a .= new();

isa-ok $a, Algorithm::Tarjan, 'module loads';

my %h = (
    a => <b c d e f>,
    b => <g h>,
    c => <i j g>,
    d => (),
    e => (),
    f => (),
    g => <k l m>,
    h => (),
    i => (),
    j => (),
    k => (),
    l => (),
    m => ()    
);
lives-ok { $a.init( %h ) }, 'test graph, no cycles loads';
lives-ok { $a.strong-components()}, 'get strong components without dying';
is-deeply $a.strongly-connected.flat, (), 'trivial list of strong components';

%h = (
    a => <b c d e f>,
    b => <g h>,
    c => <i j g>,
    d => (),
    e => (),
    f => (),
    g => <k l m>
);
lives-ok { $a.init( %h ) }, 'test graph, no cycles loads, but missing nodes in hash';
$a.strong-components();
is-deeply $a.strongly-connected.flat, (), 'trivial list of strong components';
is $a.find-cycles, 0, 'no cycles in graph';

%h = (
    a => <b c d e f>,
    b => <g h>,
    c => <i j g>,
    d => (),
    e => (),
    f => (),
    g => <k l m>,
    h => (),
    i => (),
    j => (),
    k => (),
    l => (),
    m => ('a', )    
);
$a.init( %h );
$a.strong-components();
is-deeply $a.strongly-connected.list, ['a,b,c,g,m'], 'list of strong components in graph';
is $a.find-cycles, 1, 'A cycle in graph';

%h = (
    a => ('b', ),
    b => ('c', ),
    c => ('a', ),
    d => <b c e>,
    e => <d f>,
    f => <c g>,
    g => ('f',),
    h => <e g h>    
);
$a.init( %h );
$a.strong-components();
is-deeply $a.strongly-connected.list, ['a,b,c', 'f,g', 'd,e'], 'deals with graph in Wikipedia article';
is $a.find-cycles, 3, 'Three cycles in graph';

%h = (
    MinModel => <a b c>,
    a => <a1 b2>,
    a1 => (),
    b => ('b1',),
    b1 => <a1 b3 b4 b5>,
    b2 => <b3 b4 c>,
    b3 => (),
    b4 => (),
    b5 => (),
    c => ('c1',),
    c1 => <c2 b1 a b3 b4>,
    c2 => ()
);

done-testing();
