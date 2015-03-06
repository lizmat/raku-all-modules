class Inline::Lua;

use Lua::Raw;
use Inline::Lua::Object;

our $.default-lua = Any;

has $.raw = die 'raw is required';
has $.state = self.new-state;
has $.index = self.new-index;
has %.refcount;
has %.ptrref;

method new (Bool :$auto, Str :$lua, Str :$lib, :$raw, |args) {
    my $new;
    if !$raw && $auto !eqv False && ($lib, $lua)».defined.none {
        $new = try { self.new: :lua<JIT>, |args };
        $new //= self.new: :!auto, |args;
    } else {
        when !$raw {
            my %raw-args = (:$lua, :$lib).grep: *.value.defined;
            $new = self.new: :raw(Lua::Raw.new: |%raw-args), |args;
        }
        $new = callsame;
    }
    Inline::Lua.default-lua = $new;
}

method new-state () {
    my $L = $!raw.luaL_newstate;
    $!raw.luaL_openlibs: $L;

    $L;
}

method new-index () {
    $!raw.lua_createtable: $!state, 0, 0;
    $!raw.lua_gettop: $!state;
}

method ref-to-stack ($ref) {
    $!raw.lua_rawgeti: $!state, $!index, $ref;
}

method ref-from-stack (:$keep, :$weak) {
    my $ptr = $!raw.lua_topointer: $!state, -1;
    my $ref := %!ptrref{+$ptr};

    if !defined $ref {
        $ref = $!raw.luaL_ref: $!state, $!index;
        $!raw.lua_rawgeti: $!state, $!index, $ref if $keep;
    } else {
        $!raw.lua_settop: $!state, -2 unless $keep;
    }

    %!refcount{$ref}++ unless $weak;

    $ref;
}

method unref ($ref) {
    unless --%!refcount{$ref} {
        %!refcount{$ref} :delete;
        $!raw.luaL_unref: $!state, $!index, $ref;
    }
}

method require (Str:D $name, :$set) {
    state &lua-require //= self.get-global: 'require';

    my $table = lua-require $name;

    self.set-global: $name, $table if $set eqv True;

    $table;
}

method get-global (Str:D $name) {
    self!get-global: $name;
    self.value-from-lua;
}

method !get-global (Str:D $name) {
    $!raw.lua_getfield: $!state, $!raw.LUA_INDEX<GLOBALS>, $name;
}

method set-global (Str:D $name, $val) {
    self.value-to-lua: $val;
    self!set-global: $name;
}

method !set-global (Str:D $name) {
    $!raw.lua_setfield: $!state, $!raw.LUA_INDEX<GLOBALS>, $name;
}

method run (Str:D $code, *@args) {
    self.ensure:
        :e<Compilation failed>,
        $!raw.luaL_loadstring: $!state, $code;

    self!call: @args;
}

method call (Str:D $name, *@args) {
    self!get-global: $name;
    self!call: @args;
}

method !call (*@args) {
    # - 1 excludes the function we're about to pop via pcall
    my $top = $!raw.lua_gettop($!state) - 1;

    self.values-to-lua: @args;

    self.ensure:
        :e<Execution failed>,
        $!raw.lua_pcall: $!state, +@args, -1, 0;

    self.values-from-lua: $!raw.lua_gettop($!state) - $top;
}

method values-from-lua (Int:D $count, |args) {
    $count == 1 ??
        self.value-from-lua(|args)
    !!
        (^$count).map({ self.value-from-lua(|args) }).reverse # won't work with :keep
    if $count;
}

method value-from-lua (:$keep) {
    $_ = $!raw.lua_typename: $!state, $!raw.lua_type: $!state, -1;

    when 'table' { Inline::Lua::Table.new: :lua(self), :stack, :$keep }
    when 'function' { Inline::Lua::Function.new: :lua(self), :stack, :$keep }

    my $val = do {
        when 'boolean' { ?$!raw.lua_toboolean: $!state, -1 }
        when 'number'  { +$!raw.lua_tonumber:  $!state, -1 }
        when 'string'  { ~$!raw.lua_tolstring:  $!state, -1 }
        when 'nil'     { Any }
        Failure;
    };

    $!raw.lua_settop: $!state, -2 unless $keep;

    fail "Converting Lua $_ values to Perl is NYI" if $val ~~ Failure;

    $val;
}

method values-to-lua (*@vals) {
    self.value-to-lua: $_ for @vals;
}

method value-to-lua ($_) {
    when !.defined { $!raw.lua_pushnil: $!state }
    when Bool { $!raw.lua_pushboolean: $!state, Int($_) }
    when Inline::Lua::TableObj { $_.inline-lua-table.get }
    when Inline::Lua::Object { $_.get }
    when Positional | Associative {
        $!raw.lua_createtable: $!state, 0, 0;
        if $_ ~~ Positional {
            my $key = 1;
            for .list {
                self.value-to-lua: $key++;
                self.value-to-lua: $_;
                $!raw.lua_rawset: $!state, -3;
            }
        }
        if $_ ~~ Associative {
            for .pairs {
                self.value-to-lua: .key;
                self.value-to-lua: .value;
                $!raw.lua_rawset: $!state, -3;
            }
        }
    }
    when Numeric { $!raw.lua_pushnumber: $!state, Num($_) }
    when Stringy { $!raw.lua_pushstring: $!state, ~$_ }

    fail "Converting $_.WHAT().^name() values to Lua is NYI";
}

method ensure ($code, :$e is copy) {
    if $code {
        my $msg = "Error $code $!raw.LUA_STATUS(){$code}";
        fail $e ?? "$e\n$msg" !! $msg;
    }
}

role LuaParent[Str:D $parent] is export {
    method sink () { self }
    method FALLBACK (|args) {
        Inline::Lua.default-lua.get-global($parent).invoke: |args;
    }
}

#`[[[ has problems, one being that $parent is needed at compose time
role LuaParent[Inline::Lua::Table:D $parent] {
    method sink () { self }
    method FALLBACK (|args) {
        $parent.invoke: |args;
    }
}
#]]]


