class Inline::Lua;

use Lua::Raw;

has $!L = self!build_state;

method !build_state () {
    my $L = Lua::Raw::luaL_newstate;
    Lua::Raw::luaL_openlibs $L;

    $L;
}

method get-global (Str:D $name, Bool :$func) {
    self!get-global: $name;

    my $return =
        ( $func // (Lua::Raw::lua_typename($!L, Lua::Raw::lua_type $!L, -1) eq 'function') ) ??
            self.^lookup('call')[0].assuming(self, $name) !!
            self!value-to-perl: -1;

    Lua::Raw::lua_settop $!L, -2;

    $return;
}

method !get-global (Str:D $name) {
    my constant $global-index = %LUA_INDEX<GLOBALS>;
    Lua::Raw::lua_getfield $!L, $global-index, $name;
}

method set-global (Str:D $name, $val) {
    self!value-to-lua: $val;
    self!set-global: $name;
}

method !set-global (Str:D $name) {
    my constant $global-index = %LUA_INDEX<GLOBALS>;
    Lua::Raw::lua_setfield $!L, $global-index, $name;
}

method run (Str:D $code, *@args) {
    ensure
        :e<Compilation failed>,
        Lua::Raw::luaL_loadstring $!L, $code;

    self!call: @args;
}

method call (Str:D $name, *@args) {
    self!get-global: $name, :func;
    self!call: @args;
}

method !call (*@args) {
    my $top = Lua::Raw::lua_gettop($!L) - 1;

    self!values-to-lua: @args;

    ensure
        :e<Execution failed>,
        Lua::Raw::lua_pcall $!L, +@args, -1, 0;

    my @return;
    my $elems = Lua::Raw::lua_gettop($!L) - $top;
    
    if $elems > 1 {
        @return.push: self!value-to-perl($top + $_) for 1..$elems;
        Lua::Raw::lua_settop $!L, $top;
    } elsif $elems == 1 {
        @return = self!value-to-perl: $top + 1;
        Lua::Raw::lua_settop $!L, $top;
    }

    return |@return;
}

method !value-to-perl (Int:D $i is copy) {
    $i = Lua::Raw::lua_gettop($!L) + $i + 1 if $i < 0;
    $_ = Lua::Raw::lua_typename $!L, Lua::Raw::lua_type $!L, $i;

    when 'boolean' { ?Lua::Raw::lua_toboolean $!L, $i };
    when 'number'  { +Lua::Raw::lua_tonumber  $!L, $i };
    when 'string'  { ~Lua::Raw::lua_tolstring  $!L, $i };
    when 'table' {
        my %table := :{};
        Lua::Raw::lua_pushnil $!L;
        while Lua::Raw::lua_next $!L, $i {
          my $key = self!value-to-perl(-2);
          my $value = self!value-to-perl(-1);
          %table{$key} = $value;
          Lua::Raw::lua_settop $!L, -2;
        }
        return $%table;
    };

    fail "Converting Lua $_ values to Perl is NYI";
}

method !values-to-lua (*@vals) {
    self!value-to-lua: $_ for @vals;
}

method !value-to-lua ($_) {
    when !.defined { Lua::Raw::lua_pushnil $!L }
    when Bool { Lua::Raw::lua_pushboolean $!L, $_.Num }
    when Positional | Associative {
        my $positional = ($_ ~~ Positional);
        Lua::Raw::lua_createtable $!L, 0, 0;
        for .pairs {
            my $key = .key;
            $key = $key + 1 if $positional && $key ~~ Int;
            self!value-to-lua: $key;
            self!value-to-lua: .value;
            Lua::Raw::lua_rawset $!L, -3;
        }
    }
    when Numeric { Lua::Raw::lua_pushnumber $!L, $_.Num }
    when Stringy { Lua::Raw::lua_pushstring $!L, ~$_ }

    fail "Converting $_.WHAT().name() values to Lua is NYI";
}

sub ensure ($code, :$e is copy) {
    if $code {
        my $msg = "Error $code %LUA_STATUS{$code}";
        fail $e ?? "$e\n$msg" !! $msg;
    }
}

