use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 1;
# this test is done in isolation
{
   use re-exportglobalish;
   ok GLOBALish::<AGlobalishSymbol>:exists,'was imported into globalish';
}
