unit class DispatchMap does Associative;

has $.disp-obj = Metamodel::ClassHOW.new_type();
has $!dispatcher;

method !add-dispatch($ns,@key,$value) {
    use nqp;
    my role Candidate {
        has $.key is rw;
        has $.value is rw;
    }

    my $params := nqp::list();
    my $i := 0;
    for @key {
        my $param := Parameter.new;
        my $nominal-type := do if .defined {
            nqp::bindattr($param,Parameter,'$!post_constraints',nqp::list(nqp::decont($_)));
            # use the :D of the type. Rakudo caches it.
            Metamodel::DefiniteHOW.new_type(:base_type(.WHAT),:definite);
        } else {
            $_;
        }
        nqp::bindattr($param,Parameter,'$!nominal_type',nqp::decont($nominal-type));
        nqp::bindattr_i($param,Parameter,'$!flags',128);
        nqp::push($params,$param);
        $i := $i + 1;
    }
    my $method := anon sub {};
    my $sig := $method.signature.clone;
    nqp::bindattr($sig,Signature,'$!params',$params);
    nqp::bindattr($sig,Signature,'$!count',$i);
    nqp::bindattr($sig,Signature,'$!arity',$i);
    $method does Candidate;
    $method.key   = @key;
    $method.value = $value;
    nqp::bindattr($method,Code,'$!signature',$sig);
    $!disp-obj.^add_multi_method("__$ns",nqp::decont($method));
    $value;
}

method keys(Str:D $ns)   { self.dispatcher($ns).candidates.map(*.key)   }
method values(Str:D $ns) { self.dispatcher($ns).candidates.map(*.value) }
method pairs(Str:D $ns)  { self.dispatcher($ns).candidates.map( { .key => .value } ) }

method !compose(){ self.disp-obj.^compose }

method new(|c) {
    my $new = self.bless;
    $new.append(|c);
    $new;
}

method make-child(|c) {
    my $new = self.bless;
    $new.disp-obj.^add_parent(self.disp-obj);
    $new.append(|c);
    $new;
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
    self!compose;
}

method list(Str:D $ns)  { self.pairs($ns).map({slip .key,.value }).list }
method namespaces { $!disp-obj.^method_table.keys.grep(/^'__'/).map(*.subst(/^'__'/,'')) }
