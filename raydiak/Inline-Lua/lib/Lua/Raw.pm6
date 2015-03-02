class Lua::Raw;

use NativeCall;

our sub luaL_newstate ()
    returns OpaquePointer
{...}

our sub luaL_openlibs (
    OpaquePointer $ )
{...}

our sub luaL_loadstring (
    OpaquePointer $,
    Str $ )
    returns int32
{...}

our sub lua_pcall (
    OpaquePointer $,
    int32 $,
    int32 $,
    int32 $ )
    returns int32
{...}

our sub lua_type (
    OpaquePointer $,
    int32 $ )
    returns int32
{...}

our sub lua_typename (
    OpaquePointer $,
    int32 $ )
    returns Str
{...}

our sub lua_toboolean (
    OpaquePointer $,
    int32 $ )
    returns int32
{...}

our sub lua_tonumber (
    OpaquePointer $,
    int32 $ )
    returns num64
{...}

our sub lua_tolstring (
    OpaquePointer $,
    int32 $,
    OpaquePointer $ = OpaquePointer )
    returns Str
{...}

our sub lua_gettop (
    OpaquePointer $ )
    returns int32
{...}

our sub lua_settop (
    OpaquePointer $,
    int32 $ )
{...}

our sub lua_next (
    OpaquePointer $,
    int32 $ )
    returns int32
{...}

our sub lua_pushnil (
    OpaquePointer $ )
{...}

our sub lua_pushnumber (
    OpaquePointer $,
    num64 $ )
{...}

our sub lua_pushstring (
    OpaquePointer $,
    Str $ )
{...}

our sub lua_pushboolean (
    OpaquePointer $,
    int32 $ )
{...}

our sub lua_createtable (
    OpaquePointer $,
    int32 $ = 0,
    int32 $ = 0 )
{...}

our sub lua_rawgeti (
    OpaquePointer $,
    int32 $,
    int32 $ )
{...}

our sub lua_rawset (
    OpaquePointer $,
    int32 $ )
{...}

our sub lua_getfield (
    OpaquePointer $,
    int32 $,
    Str $ )
{...}

our sub lua_setfield (
    OpaquePointer $,
    int32 $,
    Str $ )
{...}

our sub luaL_ref (
    OpaquePointer $,
    int32 $ )
    returns int32
{...}

our sub luaL_unref (
    OpaquePointer $,
    int32 $,
    int32 $ )
{...}

our sub lua_topointer (
    OpaquePointer $,
    int32 $ )
    returns OpaquePointer
{...}

our sub lua_objlen (
    OpaquePointer $,
    int32 $ )
    returns int32
{...}

our sub lua_gettable (
    OpaquePointer $,
    int32 $ )
{...}

our %.LUA_STATUS =
    1 => 'YIELD',
    2 => 'ERRRUN',
    3 => 'ERRSYNTAX',
    4 => 'ERRMEM',
    5 => 'ERRERR';

our %.LUA_INDEX =
    REGISTRY => -10000,
    ENVIRON => -10001,
    GLOBALS => -10002;

has $.lua = '5.1';
has $.lib = do {
    my $lib = $!lua;
    $lib = 'jit-5.1' if $lib.uc eq 'JIT';
    warn "Attempting to use unsupported Lua version '$lib'; this is likely to fail"
        if $lib ∉ <5.1 jit-5.1>;
    $lib = "lua$lib";
    $lib = "lib$lib" unless $*VM.config<dll> ~~ /dll/;
};

has %.subs =
    Lua::Raw::.grep({ .key ~~ /^ \&luaL?_/ })».value.map: {
        # runtime NativeCall technique forked from Inline::Python
        $_.name => trait_mod:<is>($_.clone, :native(self.lib));
    };

method FALLBACK ($name, |args) { %!subs{$name}(|args) }


