use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 10;

{
    use re-exports-stuff;
    ok foo(), 'EXPORT::DEFAULT symbol was re-exported';
    ok ::('&dont-clobber'), 're-export doesn\'t clobber';
}

{
    use re-exports-EXPORT;
    ok bar(), 'sub EXPORT symbol was re-exported';
    nok ::('&foo'), 'steal-export-sub only does that';
}

{
    eval-lives-ok 'use re-exports-nothing;','re-exporting from empty file doesnt die';
}


{
    use re-exporthow;
    lives-ok { my pokemon pikachu { } },'pikachu re-exported';
    lives-ok { my digimon augmon { }  },'digimon not clobbered';
    skip 'RT #131584', 1;
    #ok ( grammar { } ).HOW ~~ Metamodel::ClassHOW, 'SUPERSEDE grammar is re-exported'
}

{
    use re-exporthow2;
    lives-ok { pokemon pikachu { } },'pikachu re-exported';
}

{
    eval-lives-ok 'use re-exporthow3;', <re-exporthow on empty file doesnt die>;
}
