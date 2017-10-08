role Inline::Lua::Object::Callable {
    also is Callable; # why not 'does'? https://rt.perl.org/Public/Bug/Display.html?id=124006
    has $.signature handles <arity count> = :(|);

    method call (**@args, :$stack) {
        self.get unless $stack;

        my $top = self.lua.raw.lua_gettop(self.lua.state) - 1;

        self.lua.values-to-lua: @args;

        self.lua.ensure:
            :e<Execution failed>,
            self.lua.raw.lua_pcall: self.lua.state, +@args, -1, 0;

        self.lua.values-from-lua: self.lua.raw.lua_gettop(self.lua.state) - $top;
    }

    method CALL-ME (|args) { self.call: |args }
}



class Inline::Lua::WrapperObj {
    # making this private with an explicit public accessor breaks the circular
    # ref loop for e.g. .perl()
    has $!inline-lua-object;
    method inline-lua-object () { $!inline-lua-object }

    multi submethod BUILD (:object($!inline-lua-object), |) {
        nextsame;
    }

    method sink () { self }
    method FALLBACK (|args) is rw {
        $!inline-lua-object.invoke: |args;
    }
}



class Inline::Lua::Function {...}
role Inline::Lua::Object::Indexable {
    also does Positional;
    also does Associative;
    method of () { Mu } # resolve conflict between the two above



    ### positional stuff

    method EXISTS-POS ($pos, |args) { self.EXISTS-KEY: $pos + 1, |args }

    method AT-POS ($pos, |args) is rw { self.AT-KEY: $pos + 1, |args }

    method ASSIGN-POS ($pos, |args) is rw { self.ASSIGN-KEY: $pos + 1, |args }

    method DELETE-POS ($pos, |args) { self.DELETE-KEY: $pos + 1, |args }



    ### associative stuff

    method EXISTS-KEY ($key, :$stack, :$leave = $stack) {
        self.get unless $stack;
        self.lua.value-to-lua: $key;
        self.lua.raw.lua_gettable: self.lua.state, -2;
        my $ret = self.lua.raw.lua_isnil: self.lua.state, -1;
        self.lua.raw.lua_settop: self.lua.state, $leave ?? -2 !! -3;
        ?$ret;
    }

    method AT-KEY ($self: $key, :$stack, :$leave = $stack) is rw {
        my $lua = self.lua; my ($raw, $state) = $lua.raw, $lua.state;
        Proxy.new: FETCH => method () {
            $self.get unless $stack;
            $lua.value-to-lua: $key;
            $raw.lua_gettable: $state, -2;
            my $val = $lua.value-from-lua;
            $raw.lua_settop: $state, -2 unless $leave;
            $val;
        },
        STORE => method ($val) { $self.ASSIGN-KEY($key, $val, :$stack, :$leave) };
    }

    method ASSIGN-KEY ($key, $val, :$stack, :$leave = $stack) is rw {
        my $lua = self.lua; my ($raw, $state) = $lua.raw, $lua.state;
        self.get unless $stack;
        $lua.value-to-lua: $key;
        $lua.value-to-lua: $val;
        $raw.lua_settable: $state, -3;
        $raw.lua_settop: $state, -2 unless $leave;
        self.AT-KEY: $key, :$stack, :$leave;
    }

    method DELETE-KEY ($key, :$stack, :$leave = $stack) {
        self.get unless $stack;
        my $val = my $elem := self.AT-KEY($key, :stack);
        $elem = Any;
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        $val;
    }



    ### object stuff

    method invoke ($method, :$call, |args) is rw {
        my $val = $method;
        $val := self.AT-KEY($val) unless $val ~~ Callable;
        my $cur-val = $val;

        $call !eqv False && $cur-val ~~ Inline::Lua::Function ??
            $cur-val(self, |args) !! $val;
    }

    has $.obj handles ** = Inline::Lua::WrapperObj.new: object => self;
    method sink () { self } # required for above
}



role Inline::Lua::Object::Iterable {
    method STORE (\vals) {
        self.get;
        self.ASSIGN-KEY: $_, Any, :stack for self.keys: :stack;
        my @vals = vals.flat;
        my $i = 0;
        for @vals {
            when Pair { self.ASSIGN-KEY: .key, .value, :stack }
            self.ASSIGN-POS: $i++, $_, :stack;
        }
        self.lua.raw.lua_settop: self.lua.state, -2;
        self;
    }

    method elems (|args) {Int( max 0, |(self.keys(|args).grep: Numeric) )}

    method end (|args) { self.elems(|args) - 1 }

    method list (:$stack, :$leave = $stack) {
        self.get unless $stack;
        my @vals;
        @vals[$_] = self.AT-POS($_, :stack) for ^self.elems: :stack;
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        @vals;
    }

    method keys (:$stack, :$leave = $stack) {
        self.get unless $stack;
        my @ret;
        self.lua.raw.lua_pushnil: self.lua.state;
        while self.lua.raw.lua_next: self.lua.state, -2 {
            self.lua.raw.lua_settop: self.lua.state, -2;
            @ret[+*] = self.lua.value-from-lua: :keep;
        }
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        @ret;
    }

    method values (:$stack, :$leave = $stack) {
        self.get unless $stack;
        my @ret;
        self.lua.raw.lua_pushnil: self.lua.state;
        while self.lua.raw.lua_next: self.lua.state, -2 {
            @ret[+*] = self.lua.value-from-lua;
        }
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        @ret;
    }

    # why not 'handles'? https://rt.perl.org/Public/Bug/Display.html?id=124007
    method kv (|args) { self.hash(|args).kv }
    method pairs (|args) { self.hash(|args).pairs }
    method hash (:$stack, :$leave = $stack) {
        self.get unless $stack;
        my %ret{Any};
        self.lua.raw.lua_pushnil: self.lua.state;
        while self.lua.raw.lua_next: self.lua.state, -2 {
            my \v = self.lua.value-from-lua;
            my \k = self.lua.value-from-lua: :keep;
            %ret{k} = v;
        }
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        %ret;
    }
}



role Inline::Lua::Object {
    also does Inline::Lua::Object::Indexable;
    also does Inline::Lua::Object::Callable;

    has $.lua = die "lua is required";
    has $.ref = die "ref is required";
    has $.ptr = die "ptr is required";

    multi method new (:$stack, :$lua!, :$keep, |args) {
        if :$stack {
            my $ptr = $lua.raw.lua_topointer: $lua.state, -1;
            nextwith :ref($lua.ref-from-stack: :$keep, :$ptr), :$ptr, :$lua, |args;
        }
        nextsame;
    }

    method get () {
        $!lua.ref-to-stack: $!ref;

        self;
    }

    method unref () {
        if defined $!ref {
            $!lua.unref: $!ref;
            $!ref = Any;
        }

        self;
    }

    multi submethod DESTROY (|) {
        self.unref;
        nextsame;
    }

    method length () {
        self.get;
        my $len = $!lua.raw.lua_objlen: $!lua.state, -1;
        $!lua.raw.lua_settop: $!lua.state, -2;

        $len;
    }
}



class Inline::Lua::Table does Inline::Lua::Object {
    also does Inline::Lua::Object::Iterable;

    multi method new (:$stack, :$lua!, |args) {
        nextsame if $stack;
        $lua.raw.lua_createtable: $lua.state, 0, 0;
        nextwith :stack, :$lua, |args;
    }
}



class Inline::Lua::Function does Inline::Lua::Object { }
class Inline::Lua::Userdata does Inline::Lua::Object { }
class Inline::Lua::Cdata does Inline::Lua::Object { }




