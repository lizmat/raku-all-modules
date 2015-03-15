class Lua::Raw;

use NativeCall;

our sub luaL_newstate ()
    returns Pointer[void]
{...}

our sub luaL_openlibs (
    Pointer[void] $ )
{...}

our sub luaL_loadstring (
    Pointer[void] $,
    Str $ )
    returns int32
{...}

our sub lua_pcall (
    Pointer[void] $,
    int32 $,
    int32 $,
    int32 $ )
    returns int32
{...}

our sub lua_type (
    Pointer[void] $,
    int32 $ )
    returns int32
{...}

our sub lua_typename (
    Pointer[void] $,
    int32 $ )
    returns Str
{...}

our sub lua_toboolean (
    Pointer[void] $,
    int32 $ )
    returns int32
{...}

our sub lua_tonumber (
    Pointer[void] $,
    int32 $ )
    returns num64
{...}

our sub lua_tolstring (
    Pointer[void] $,
    int32 $,
    Pointer[void] $ = Pointer[void] )
    returns Str
{...}

our sub lua_gettop (
    Pointer[void] $ )
    returns int32
{...}

our sub lua_settop (
    Pointer[void] $,
    int32 $ )
{...}

our sub lua_next (
    Pointer[void] $,
    int32 $ )
    returns int32
{...}

our sub lua_pushnil (
    Pointer[void] $ )
{...}

our sub lua_pushnumber (
    Pointer[void] $,
    num64 $ )
{...}

our sub lua_pushstring (
    Pointer[void] $,
    Str $ )
{...}

our sub lua_pushboolean (
    Pointer[void] $,
    int32 $ )
{...}

our sub lua_pushlightuserdata (
    Pointer[void] $,
    Pointer $ )
{...}

our sub lua_createtable (
    Pointer[void] $,
    int32 $ = 0,
    int32 $ = 0 )
{...}

our sub lua_rawgeti (
    Pointer[void] $,
    int32 $,
    int32 $ )
{...}

our sub lua_rawset (
    Pointer[void] $,
    int32 $ )
{...}

our sub lua_getfield (
    Pointer[void] $,
    int32 $,
    Str $ )
{...}

our sub lua_setfield (
    Pointer[void] $,
    int32 $,
    Str $ )
{...}

our sub luaL_ref (
    Pointer[void] $,
    int32 $ )
    returns int32
{...}

our sub luaL_unref (
    Pointer[void] $,
    int32 $,
    int32 $ )
{...}

our sub lua_topointer (
    Pointer[void] $,
    int32 $ )
    returns Pointer[void]
{...}

our sub lua_objlen (
    Pointer[void] $,
    int32 $ )
    returns int32
{...}

our sub lua_gettable (
    Pointer[void] $,
    int32 $ )
{...}

our sub lua_settable (
    Pointer[void] $,
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

has $.lua;
has $.lib = do {
    my $lib = ($!lua //= '5.1');
    $lib = 'jit-5.1' if $lib.uc eq 'JIT';
    warn "Attempting to use unsupported Lua version '$lib'; this is likely to fail"
        if $lib ∉ <5.1 jit-5.1>;
    $lib = "lua$lib";
    $lib = "lib$lib" unless $*VM.config<dll> ~~ /dll/;
};

# mainly make this private to omit from .perl
has %!subs =
    Lua::Raw::.grep({ .key ~~ /^ \&luaL?_/ })».value.map: {
        # runtime NativeCall technique forked from Inline::Python
        $_.name => trait_mod:<is>($_.clone, :native(self.lib));
    };


method sink () { self }
method FALLBACK ($name, |args) { %!subs{$name}(|args) }


