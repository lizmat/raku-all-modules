# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC::NC;
use TinyCC::Types;

my enum  <LOAD SET DEF INC TARGET DECL COMP RELOC DONE>;
my constant TARGETS = <_ MEM EXE DLL OBJ PRE>;

my class X::TinyCC is Exception {}

my class X::TinyCC::OutOfOrder is X::TinyCC {
    has $.action;
    has $.stage;
    method message { "Cannot perform '$!action' during stage $!stage" }
}

my class X::TinyCC::NotFound is X::TinyCC {
    has @.candidates;
    method message {
        "Could not find TinyCC at any of\n" ~
            @!candidates.map({ "  $_\n" }).join;
    }
}

my class X::TinyCC::WrongTarget is X::TinyCC {
    has $.action;
    has $.target;
    method message { "Cannot do '$!action' targeting { TARGETS[$.target] }" }
}

my class X::TinyCC::FailedCall is X::TinyCC {
    has $.call;
    method message { "The call to tcc_$!call\() failed" }
}

use MONKEY-TYPING;
augment class TCCState {
    use nqp;
    method new($value) { nqp::box_i(nqp::unbox_i($value), TCCState) }
    method Numeric { nqp::unbox_i(self) }
    method gist { "TCCState|{ self.Numeric.base(16) }" }
    method perl { "TCCState.new({ self.Numeric.base(16) })" }
}

class TinyCC {
                        # what happens on reuse:
    has $.state;        # always destroyed
    has $.stage = LOAD; # always adjusted
    has $!api;          # kept by default
    has @!candidates;   # discarded by default
    has $!root;         # kept by default
    has %!settings;     # kept by default
    has %!defs;         # kept by default
    has %!decls;        # discarded by default
    has $!target = 1;   # kept by default
    has @!code;         # discarded by default
    has $!errhandler;   # discarded by default
    has $!errpayload;   # discarded by default

    submethod DESTROY { self!DELETE }

    method gist { "TinyCC|$!stage" }

    method load(*@candidates) {
        X::TinyCC::OutOfOrder.new(:action<load>, :$!stage).fail
            if $!stage > LOAD;

        @!candidates = @candidates || %*ENV<LIBTCC> || 'libtcc';
        $!stage = SET;
        self;
    }

    method set($opts?,
        :$I, :$isystem, :$L, :$l,
        Bool :$nostdlib, Bool :$nostdinc, *% ()) {

        X::TinyCC::OutOfOrder.new(:action<set>, :$!stage).fail
            if $!stage > SET;

        %!settings<nostdlib> = True if $nostdlib;
        %!settings<nostdinc> = True if $nostdinc;
        %!settings.push:
            defined($opts) ?? :$opts !! Empty,
            defined($I) ?? :$I !! Empty,
            defined($isystem) ?? :$isystem !! Empty,
            defined($L) ?? :$L !! Empty,
            defined($l) ?? :$l !! Empty;

        self;
    }

    method setroot($root) {
        X::TinyCC::OutOfOrder.new(:action<setroot>, :$!stage).fail
            if $!stage > SET;

        $!root = $root;
        self;
    }

    method define(*%defs) {
        X::TinyCC::OutOfOrder.new(:action<define>, :$!stage).fail
            if $!stage > DEF;

        %!defs = %(%!defs, %defs);
        $!stage = DEF;
        self;
    }

    method include(*@headers) {
        X::TinyCC::OutOfOrder.new(:action<include>, :$!stage).fail
            if $!stage > INC;

        @!code.append: @headers.map({ "#include \"$_\"" });
        $!stage = INC;
        self;
    }

    method sysinclude(*@headers) {
        X::TinyCC::OutOfOrder.new(:action<sysinclude>, :$!stage).fail
            if $!stage > INC;

        @!code.append: @headers.map({ "#include <$_>" });
        $!stage = INC;
        self;
    }

    proto method target(*%) {
        X::TinyCC::OutOfOrder.new(:action<target>, :$!stage).fail
            if $!stage > TARGET;

        {*}
        $!stage = DECL;
        self;
    }

    multi method target(Bool :$MEM!, *% ()) { $!target = 1 }
    multi method target(Bool :$EXE!, *% ()) { $!target = 2 }
    multi method target(Bool :$DLL!, *% ()) { $!target = 3 }
    multi method target(Bool :$OBJ!, *% ()) { $!target = 4 }
    multi method target(Bool :$PRE!, *% ()) { $!target = 5 }

    method declare(*%decls) {
        X::TinyCC::OutOfOrder.new(:action<declare>, :$!stage).fail
            if $!stage > DECL;

        %!decls = %(%!decls, %decls);
        $!stage = DECL;
        self;
    }

    proto method compile(|) {
        X::TinyCC::OutOfOrder.new(:action<compile>, :$!stage).fail
            if $!stage > COMP;

        {*}
        $!stage = COMP;
        self;
    }

    multi method compile(Str $code) {
        @!code.push: $code;
    }

    multi method compile(Routine $r, Str $body) {
        my $name := $r.name;
        my $sig := cparams($r.signature.params).join(', ');
        my $type := ctype($r.signature.returns);
        @!code.push: qq:to/__END__/;
            $type $name\($sig) \{
            { $body.chomp.indent(4) }
            }
            __END__
    }

    method relocate {
        X::TinyCC::OutOfOrder.new(:action<relocate>, :$!stage).fail
            if $!stage != COMP;

        X::TinyCC::WrongTarget.new(:action<relocate>, :$!target).fail
            if $!target != 1;

        self!COMPILE;
        X::TinyCC::FailedCall.new(:call<relocate>).fail
            if $!api<relocate>($!state, api.RELOCATE_AUTO) < 0;

        $!stage = RELOC;
        self;
    }

    multi method lookup(Str $name) {
        self.relocate if $!stage < RELOC;
        X::TinyCC::OutOfOrder.new(:action<lookup>, :$!stage).fail
            if $!stage != RELOC;

        $!api<get_symbol>($!state, $name);
    }

    multi method lookup(Str $name, Mu:U $type) {
        nc.cast-to-ptr-of($type, self.lookup($name));
    }

    multi method lookup(Str $name, Mu:U :$var!) is rw {
        my $ptr := self.lookup($name);
        nc.cast-to-array($var, $ptr).AT-POS(0);
    }

    method run(*@args) {
        X::TinyCC::OutOfOrder.new(:action<run>, :$!stage).fail
            if $!stage != COMP;

        X::TinyCC::WrongTarget.new(:action<run>, :$!target).fail
            if $!target != 1;

        self!COMPILE;
        my $rv = $!api<run>($!state, +@args, nc.array(Str, ~<<@args, Str));
        self!DELETE;
        $rv;
    }

    method dump(Str() $path) {
        X::TinyCC::OutOfOrder.new(:action<dump>, :$!stage).fail
            if $!stage != COMP;

        X::TinyCC::WrongTarget.new(:action<dump>, :$!target).fail
            unless $!target == 2|3|4;

        self!COMPILE;
        X::TinyCC::FailedCall.new(:call<output_file>).fail
            if $!api<output_file>($!state, $path) < 0;

        self!DELETE;
        self;
    }

    method discard {
        self!DELETE;
        $!stage = LOAD;
        $!api := Nil;
        @!candidates = ();
        $!root = Nil;
        %!settings = ();
        %!defs = ();
        %!decls = ();
        $!target = 1;
        @!code = ();
        $!errhandler = Nil;
        $!errpayload = Nil;

        self;
    }

    method reuse(Bool :$api, Bool :$candidates, Bool :$root, Bool :$settings,
            Bool :$defs, Bool :$decls, Bool :$target, Bool :$code,
            Bool :$errhandler, Bool :$errpayload) {

        self!DELETE;

        if $api === False {
            $!api := Nil ;
            $!stage = LOAD;
        }
        else { $!stage = SET }

        @!candidates = () unless $candidates === True;
        $!root = Nil if $root === False;
        %!settings if $settings === False;
        %!defs if $defs === False;
        %!decls unless $decls === True;
        $!target = 1 if $target === False;
        @!code = () unless $code === True;
        $!errhandler = Nil unless $errhandler === True;
        $!errpayload = Nil unless $errhandler === True;

        $!stage = COMP if $code === True;

        self;
    }

    method catch(&cb, :$payload) {
        X::TinyCC::OutOfOrder.new(:action<catch>, :$!stage).fail
            if $!stage == DONE;

        $!errhandler = &cb;
        $!errpayload = $payload;
        self;
    }

    method !DELETE {
        $!api<delete>($!state) if $!state;
        $!state := Nil;
        $!stage = DONE;
    }

    method !COMPILE {
        self!LOAD;

        $!api<set_lib_path>($!state, $_) with $!root || %*ENV<TCCROOT> || Nil;

        for %!settings<opts nostdinc I isystem nostdlib L l>:kv ->
                $opt, $values {

            for @$values -> $value {
                my $call;
                X::TinyCC::FailedCall.new(:$call).fail
                        if $_ < 0 given do given $opt {
                    when 'opts' {
                        $!api{$call = 'set_options'}($!state, ~$value);
                    }

                    when 'nostdinc' {
                        $!api{$call = 'set_options'}($!state, '-nostdinc');
                    }

                    when 'I' {
                        $!api{$call = 'add_include_path'}($!state, ~$value);
                    }

                    when 'isystem' {
                        $!api{$call = 'add_sysinclude_path'}($!state, ~$value);
                    }

                    when 'L' {
                        $!api{$call = 'add_library_path'}($!state, ~$value);
                    }

                    when 'l' {
                        $!api{$call = 'add_library'}($!state, ~$value);
                    }

                    when 'nostdlib' {
                        $!api{$call = 'set_options'}($!state, '-nostdlib');
                    }
                }
            }
        }

        $!api<set_error_func>($!state, $!errpayload, $!errhandler)
            if defined $!errhandler;

        $!api<define_symbol>($!state, .key, ~.value)
            for %!defs.pairs;

        X::TinyCC::FailedCall.new(:call<set_output_type>).fail
            if $!api<set_output_type>($!state, $!target) < 0;

        for %!decls.pairs {
            X::TinyCC::FailedCall.new(:call<add_symbol>).fail
                if $!api<add_symbol>($!state, .key, nc.cast-to-ptr(.value)) < 0;
        }

        X::TinyCC::FailedCall.new(:call<compile_string>).fail
            if $!api<compile_string>($!state, @!code.join("\n")) < 0;
    }

    method !LOAD {
        my @candidates = @!candidates || %*ENV<LIBTCC> || 'libtcc';

        for @candidates -> $lib {
            with try api.new-state($lib) -> $state {
                $!state := $state;
                $!api := api.load($lib);
                return;
            }
        }

        X::TinyCC::NotFound.new(:@candidates).fail;
    }
}

multi EXPORT { once Map.new  }
multi EXPORT(Whatever) { Map.new('tcc' => TinyCC.new) }
multi EXPORT(&cb) {
    cb my \tcc = TinyCC.new;
    Map.new('tcc' => tcc);
}
