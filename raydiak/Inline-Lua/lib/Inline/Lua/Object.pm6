role Inline::Lua::Object {
    has $.lua = die "lua is required";
    has $.ref = die "ref is required";

    multi method new (:$stack, :$lua!, :$keep, |args) {
        nextwith :ref($lua.ref-from-stack: :$keep), :$lua, |args if :$stack;
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
}



class Inline::Lua::Function {
    also does Inline::Lua::Object;
    also is Block;
    has $.arity = 0;
    has $.count = Inf;
    has $.signature = :(*@);

    method postcircumfix:<( )> (|args) { self.call: |args }

    method call (*@args, :$stack) {
        self.get unless $stack;

        my $top = self.lua.raw.lua_gettop(self.lua.state) - 1;

        self.lua.values-to-lua: @args;

        self.lua.ensure:
            :e<Execution failed>,
            self.lua.raw.lua_pcall: self.lua.state, +@args, -1, 0;

        self.lua.values-from-lua: self.lua.raw.lua_gettop(self.lua.state) - $top;
    }
}



class Inline::Lua::TableObj {
    # making this private with an explicit public accessor breaks the circular
    # ref loop for e.g. .perl()
    has $!inline-lua-table;
    method inline-lua-table () { $!inline-lua-table }

    multi submethod BUILD (:table($!inline-lua-table), |) {
        nextsame;
    }

    method sink () { self }
    method FALLBACK (|args) is rw {
        $!inline-lua-table.invoke: |args;
    }
}



class Inline::Lua::Table {
    also does Inline::Lua::Object;
    also does Positional;
    also does Associative;
    method of () { Mu } # resolve conflict between the two above

    multi method new (:$stack, :$lua!, |args) {
        nextsame if $stack;
        $lua.raw.lua_createtable: $lua.state, 0, 0;
        nextwith :stack, :$lua, |args;
    }

    method STORE (\vals) {
        self.get;
        self.assign_key: $_, Any, :stack for self.keys: :stack;
        my @vals = vals.flat;
        my $i = 0;
        for @vals {
            when Pair { self.assign_key: .key, .value, :stack }
            self.assign_pos: $i++, $_, :stack;
        }
        self.lua.raw.lua_settop: self.lua.state, -2;
        self;
    }



    ### positional stuff

    method elems (|args) {Int( max 0, self.keys(|args).grep: Numeric )}

    method end (|args) { self.elems(|args) - 1 }

    method exists_pos ($pos, |args) { self.exists_key: $pos + 1, |args }

    method at_pos ($pos, |args) is rw { self.at_key: $pos + 1, |args }

    method assign_pos ($pos, |args) is rw { self.assign_key: $pos + 1, |args }

    method delete_pos ($pos, |args) { self.delete_key: $pos + 1, |args }

    method list (:$stack, :$leave = $stack) {
        self.get unless $stack;
        my @vals;
        @vals[$_] = self.at_pos($_, :stack) for ^self.elems: :stack;
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        @vals;
    }



    ### associative stuff

    method exists_key ($key, :$stack, :$leave = $stack) {
        self.get unless $stack;
        self.lua.value-to-lua: $key;
        self.lua.raw.lua_gettable: self.lua.state, -2;
        my $ret = self.lua.raw.lua_isnil: self.lua.state, -1;
        self.lua.raw.lua_settop: self.lua.state, $leave ?? -2 !! -3;
        ?$ret;
    }

    method at_key ($self: $key, :$stack, :$leave = $stack) is rw {
        my $lua = self.lua; my ($raw, $state) = $lua.raw, $lua.state;
        Proxy.new: FETCH => method () {
            $self.get unless $stack;
            $lua.value-to-lua: $key;
            $raw.lua_gettable: $state, -2;
            my $val = $lua.value-from-lua;
            $raw.lua_settop: $state, -2 unless $leave;
            $val;
        },
        STORE => method ($val) { $self.assign_key($key, $val, :$stack, :$leave) };
    }

    method assign_key ($key, $val, :$stack, :$leave = $stack) is rw {
        my $lua = self.lua; my ($raw, $state) = $lua.raw, $lua.state;
        self.get unless $stack;
        $lua.value-to-lua: $key;
        $lua.value-to-lua: $val;
        $raw.lua_settable: $state, -3;
        $raw.lua_settop: $state, -2 unless $leave;
        self.at_key: $key, :$stack, :$leave;
    }

    method delete_key ($key, :$stack, :$leave = $stack) {
        self.get unless $stack;
        my $val = my $elem := self.at_key($key, :stack);
        $elem = Any;
        self.lua.raw.lua_settop: self.lua.state, -2 unless $leave;
        $val;
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

    method hash (:$stack, :$leave = $stack) handles <kv pairs> {
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



    ### object stuff

    method invoke ($method, :$call, |args) is rw {
        my $val = $method;
        $val := self.at_key($val) unless $val ~~ Callable;
        my $cur-val = $val;

        $call !eqv False && $cur-val ~~ Callable ??
            $cur-val(self, |args) !! $val;
    }

    method sink () { self }
    has $.obj handles ** = Inline::Lua::TableObj.new: table => self;
}




