use v6;

use Test;

plan 25;

my constant $root = $?FILE.IO.parent.parent;
use lib $root.child: 'lib';
use lib $root.child('blib').child: 'lib';

use Inline::Lua;

ok 1, 'Module loads successfully';

my $L;

isa_ok $L = Inline::Lua.new, Inline::Lua, '.new() works';

lives_ok { $L.run('return') }, '.run() works';

{
    my $code = q:to/END/;
        local args = {...}
        local n = 0

        for i = 1, args[1] do
            n = n + i
        end

        return n
    END
    my $arg = 1e7; # arg reduced by e1 from README
    my $answer = 5e13 + 5e6;
    my $sum;

    $sum = $L.run: $code, $arg;
    ok $sum == $answer, 'README example #1 works';

    $L.run: "function sum (...)\n $code\n end";
    $sum = $L.call: 'sum', $arg;
    ok $sum == $answer, 'README example #2 works';

    my &sum = $L.get-global: 'sum';
    $sum = sum $arg;
    ok $sum == $answer, 'README example #3 works';
}

$L.set-global: 'foo', 'bar';
ok $L.get-global('foo') eq 'bar', '.set-global() and .get-global() work';

{
    my $t = $L.run: 'return({...})', 123, "abc", True, Any, {:foo(3), :bar(77)};

    ok $t ~~ Inline::Lua::Table, 'Tables work';
    ok (my @ret = $t.list).elems == 5, 'Arrays work';
    ok @ret[4].hash eqv {:foo(3|3e0), :bar(77|77e0)}, 'Hashes work';
    ok @ret[0] == 123, 'Numbers work';
    ok @ret[1] eq 'abc', 'Strings work';
    ok @ret[2] === True, 'Bools work';
    ok @ret[3] === Any, 'Nils work';
}

{
    my $f = $L.run: 'return(function (val) return(val) end)';
    ok $f ~~ Inline::Lua::Function, 'Functions work';
    ok $f(True) === True, 'Function calls work';
}

{
    my $o = $L.run('return({
        ["Y"] = 42,
        ["plus-Y"] = function (self, X) return(X + self.Y) end
    })').obj;
    ok $o ~~ Inline::Lua::TableObj, 'Objects work';
    ok $o.Y == 42, 'Attributes work';
    ok $o.plus-Y(8) == 50, 'Method calls work';
    ok $o.plus-Y(:!call) ~~ Inline::Lua::Function, 'Method retrieval works';
    my $t = $o.inline-lua-table;
    ok $t ~~ Inline::Lua::Table, 'Inline::Lua::TableObj.inline-lua-table works';

    $L.set-global('o', $t);
    ok $L.get-global('o') ~~ Inline::Lua::Table, '.set/get-global work with objects';
    $o = LuaParent['o'].new;
    ok $o.Y == 42, 'LuaParent works';
    my class LuaClass does LuaParent['o'] {};
    ok LuaClass.Y == 42, "Composition works";
    my class LuaChild is LuaClass {};
    ok LuaChild.plus-Y(7) == 7**2, "Inheritance works";
}

done;
