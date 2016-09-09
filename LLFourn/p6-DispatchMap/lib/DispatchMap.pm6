unit class DispatchMap does Associative;

has $.disp-obj = Metamodel::ClassHOW.new_type();
has $!dispatcher;
has @!pairs;

method !add-dispatch(@key,$value) {
    use nqp;
    my role Candidate {
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
    $method.value = $value;
    nqp::bindattr($method,Code,'$!signature',$sig);
    $!disp-obj.^add_multi_method("_dispatch",nqp::decont($method));
    @!pairs.push(Pair.new(:@key,:$value));
    $value;
}

method keys   { @!pairs.map(*.key)   }
method values { @!pairs.map(*.value) }

method !compose(){
    self.disp-obj.^compose;
}

method new(**@args) {
    my $new = self.bless;
    $new.append(|@args);
    $new;
}

method dispatcher {
    $!disp-obj.^find_method("_dispatch");
}

method dispatch(|c) {
    with self.get(|c) {
        when Callable:D { $_.(|c) }
        default { $_ }
    }
}

method get(|c)     {
    self.dispatcher.cando(c)[0].?value
}
method get-all(|c) { self.dispatcher.cando(c).map(*.value) }
method exists(|c)  { self.dispatcher.cando(c)[0]:exists }

method append(**@args) {
    @args = |@args[0] if @args == 1;
    my $i = @args.iterator;
    until (my $k := $i.pull-one) =:= IterationEnd {
        my $v;
        if $k ~~ Pair {
            $v := $k.value;
            $k := $k.key;
        } else {
            $v := $i.pull-one;
        }
        $k := List.new($k) if not ($k.defined and $k ~~ Iterable);
        self!add-dispatch($k,$v);
    }
    self!compose;
}

method pairs { @!pairs.list }
method list  { @!pairs.map: {slip .key,.value } }
