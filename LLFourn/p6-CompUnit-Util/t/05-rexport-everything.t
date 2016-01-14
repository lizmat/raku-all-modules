use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 4;

{
    use re-exports-everything;
    lives-ok { pokemon pikachu { } },'exporthow';
    ok GLOBALish::<AGlobalishSymbol>:exists,'globalish';
    ok &bar.(), 'sub EXPORT';
    ok &foo.(), 'UNIT::EXPORT';
}
