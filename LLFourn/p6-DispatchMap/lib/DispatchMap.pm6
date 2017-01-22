unit class DispatchMap does Associative;

has $.disp-obj = Metamodel::ClassHOW.new_type();
has $!dispatcher;

my role Dispatcher {
    has $.meta is rw;
}

method !add-dispatch($ns,@key,$value) {
    use nqp;
    my role Candidate {
        has $.key is rw;
        has $.value is rw;
    }

    my $params := nqp::list();

    for @key {
        my $param := Parameter.new;
        my $nominal-type := do if .defined {
            nqp::bindattr($param,Parameter,'@!post_constraints',nqp::list(nqp::decont($_)));
            # use the :D of the type. Rakudo caches it.
            Metamodel::DefiniteHOW.new_type(:base_type(.WHAT),:definite);
        } else {
            $_;
        }
        nqp::bindattr($param,Parameter,'$!nominal_type',nqp::decont($nominal-type));
        nqp::bindattr_i($param,Parameter,'$!flags',128);
        nqp::push($params,$param);
    }
    my $method := anon sub {};
    my $sig := $method.signature.clone;
    nqp::bindattr($sig,Signature,'@!params',$params);
    nqp::bindattr($sig,Signature,'$!count',@key.elems);
    # nqp::bindattr($sig,Signature,'$!arity',@key.elems); # not working atm
    $method does Candidate;
    $method.key   = @key;
    $method.value = $value;
    nqp::bindattr($method,Code,'$!signature',$sig);
    $!disp-obj.^add_multi_method("__$ns",nqp::decont($method));
    $value;
}

method keys(Str:D $ns)   { self.dispatcher($ns).candidates.map(*.key).list   }
method values(Str:D $ns) { self.dispatcher($ns).candidates.map(*.value).list }
method pairs(Str:D $ns)  { self.dispatcher($ns).candidates.map( { .key => .value } ).list }

method compose(){ self.disp-obj.^compose; self; }

method new(*%ns) {
    my $new = self.bless;
    $new.append(|%ns);
    $new;
}

method add-parent(DispatchMap:D $d) {
    self.disp-obj.^add_parent($d.disp-obj);
    self;
}

method dispatcher(Str:D $ns) { $!disp-obj.^find_method("__$ns"); }

method dispatch(Str:D $ns,|c) {
    with self.get($ns,|c) {
        when Callable:D { $_.(|c) }
        default { $_ }
    }
}

method get(Str:D $ns,|c)     { self.dispatcher($ns).?cando(c)[0].?value }
method get-all(Str:D $ns,|c) { self.dispatcher($ns).?cando(c).map(*.value) }
method exists(Str:D $ns,|c)  { self.dispatcher($ns).?cando(c)[0]:exists }

method append(*%ns) {
    for %ns.kv -> $ns, $args {
        self!vivify-dispatcher($ns);
        my $i = $args.iterator;
        until (my $k := $i.pull-one) =:= IterationEnd {
            my $v;
            if $k ~~ Pair:D {
                $v := $k.value;
                $k := $k.key;
            } else {
                $v := $i.pull-one;
            }
            $k := List.new($k) if not ($k.defined and $k ~~ Iterable);
            self!add-dispatch($ns,$k,$v);
        }
    }
    self;
}

method ns-meta(Str:D $ns) is rw {
    my $d = self!vivify-dispatcher($ns);
    $ = ($d does Dispatcher if $d !~~ Dispatcher);
    return-rw $d.meta;
}

method !make-dispatcher { (my proto anon (|) {*}).derive_dispatcher }

method !vivify-dispatcher(Str:D $ns) {
    my $dispatcher = $!disp-obj.^find_method("__$ns");
    if not $dispatcher {
       $dispatcher = self!make-dispatcher;
       $!disp-obj.^add_method("__$ns",$dispatcher);
    }
    $dispatcher;
}

method override(*%ns) {
    for %ns.keys -> $ns {
        $!disp-obj.^add_method("__$ns",self!make-dispatcher);
    }
    self.append(|%ns);
    self;
}

method list(Str:D $ns)  { self.pairs($ns).map({slip .key,.value }).list }
method namespaces { $!disp-obj.^method_table.keys.grep(/^'__'/).map(*.subst(/^'__'/,'')) }
