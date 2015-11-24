use nqp;
use nqp:from<NQP>;
use MONKEY-TYPING;
use NativeCall;

sub assign(Mu:U \type, Mu:D \dest, Mu:D \value) {
    use Native::LibC <memmove>;

    die "Cannot assign { value.WHAT.gist } to { type.gist }"
        unless value ~~ type;

    memmove(nativecast(Pointer, dest), nativecast(Pointer, value),
        nativesizeof(type));
}

my class CScalarRef {
    has $!carray;

    method FETCH { $!carray.AT-POS(0) }
    method STORE(\value) { $!carray.ASSIGN-POS(0, value) }

    method ptr     { nativecast Pointer[$!carray.of], $!carray }
    method Pointer { nativecast Pointer[$!carray.of], $!carray }

    submethod BUILD(:$!carray) {}

    method from(CScalarRef:U: Pointer:D \ptr) {
        my $self := nqp::create(CScalarRef);
        my $carray := nativecast(CArray[ptr.of], ptr);
        nqp::bindattr($self, CScalarRef, '$!carray', $carray);
        $self;
    }

    method new(CScalarRef:U: Mu:U \type, \value = Nil) {
        my $carray := CArray[type].new;
        $carray[0] = value !=:= Nil ?? value !! do given ~type.REPR {
            when 'P6int' { 0 }
            when 'P6num' { 0e0 }
            when 'CPointer' { type }
            default { die "Unhandled REPR '$_'" }
        }

        my $self := nqp::create(CScalarRef);
        nqp::bindattr($self, CScalarRef, '$!carray', $carray);
        $self;
    }
}

my class CStructRef {
    has $!struct;

    method FETCH { $!struct }
    method STORE(\value) { assign $!struct.WHAT, $!struct, value }

    method ptr     { nativecast Pointer[$!struct.WHAT], $!struct }
    method Pointer { nativecast Pointer[$!struct.WHAT], $!struct }

    submethod BUILD(:$!struct) {}

    method from(CStructRef:U: Pointer:D \ptr) {
        given ~ptr.of.REPR {
            die "Unhandled REPR '$_'"
                unless $_ eq 'CStruct'
        }

        my $self := nqp::create(CStructRef);
        nqp::bindattr($self, CStructRef, '$!struct', nativecast(ptr.of, ptr));
        $self;
    }

    method new(CStructRef:U: Mu:U \type, |c) {
        my $self := nqp::create(CStructRef);
        nqp::bindattr($self, CStructRef, '$!struct', type.new(|c));
        $self;
    }
}

EVAL q:to/__END__/, :lang<nqp>;

sub FETCH($cont) {
    my $var := nqp::p6var($cont);
    nqp::decont(nqp::findmethod($var,'FETCH')($var));
}

sub STORE($cont, $value) {
    my $var := nqp::p6var($cont);
    nqp::findmethod($var, 'STORE')($var, $value);
}

my %pair := nqp::hash(
    'fetch', nqp::getstaticcode(&FETCH),
    'store', nqp::getstaticcode(&STORE)
);

nqp::setcontspec(CScalarRef, 'code_pair', %pair);
nqp::setcontspec(CStructRef, 'code_pair', %pair);

__END__

my role SizedCArray does Positional does Iterable {
    has uint $.elems;
    has CArray $.carray;

    method of { $!carray.of }
    method Pointer { nativecast(Pointer[$!carray.of], $!carray) }

    method size { $!elems * nativesizeof($!carray.of) }
    method at(uint \idx) { self.Pointer.displace(idx) }

    method iterator {
        my uint $elems = $!elems;
        my \array = self;
        (class :: does Iterator {
            has uint $!i = 0;
            method pull-one {
                $!i < $elems ?? array.AT-POS($!i++) !! IterationEnd
            }
        }).new;
    }
}

my class SizedCScalarArray does SizedCArray {
    method AT-POS(uint \idx) is rw { CScalarRef.from(self.at(idx)) }
    method ASSIGN-POS(uint \idx, \value) { $!carray[idx] = value }
}

my class SizedCStructArray does SizedCArray {
    method AT-POS(uint \idx) is rw { CStructRef.from(self.at(idx)) }
    method ASSIGN-POS(uint \idx, \value) { assign self.of, self.at(idx), value }
}

augment class CArray {
    method grab(uint \elems) {
        .new(carray => self, elems => elems) given do given ~self.of.REPR {
            when 'CStruct' { SizedCStructArray }
            when any <P6int P6num CPointer> { SizedCScalarArray }
            default { die "Unhandled REPR '$_'" }
        }
    }
}

augment class Pointer {
    my class FuncPointer {
        has Pointer $.ptr;
        has Signature $.sig;

        method invoke(|args) { !!! }
    }

    multi method as(Signature \s) {
        FuncPointer.new(sig => s, ptr => self.as(Pointer));
    }

    multi method as(Pointer:U \type) {
        nqp::box_i(nqp::unbox_i(nqp::decont(self)), nqp::decont(type));
    }

    multi method as(Int:U) {
        nqp::unbox_i(nqp::decont(self));
    }

    method to(Mu:U \type) {
        nqp::box_i(nqp::unbox_i(nqp::decont(self)), Pointer[type]);
    }

    method grab(uint \elems) {
        nativecast(CArray[self.of], self).grab(elems);
    }

    method displace(int \offset) {
        my \type = self.of;
        Pointer.new(self + nativesizeof(type) * offset).to(type);
    }

    method rv { self.deref }
    method lv is rw {
        .from(self) given do given ~self.of.REPR {
            when 'CStruct' { CStructRef }
            when any <P6int P6num CPointer> { CScalarRef }
            default { die "Unhandled REPR '$_'" }
        }
    }
}

sub cref(Mu:U \type, |c) is export {
    .new(type, |c) given do given ~type.REPR {
        when 'CStruct' { CStructRef }
        when any <P6int P6num CPointer> { CScalarRef }
        default { die "Unhandled REPR '$_'" }
    }
}

# HACK: duplicated from NaticeCall::Types to make precompilation work

augment class Pointer {
    my role TypedPointer[::TValue = void] is Pointer is repr('CPointer') {
        method of() { TValue }
        # method ^name($obj) { 'Pointer[' ~ TValue.^name ~ ']' }
        method deref(::?CLASS:D \ptr:) { nativecast(TValue, ptr) }
    }

    Pointer.HOW.^can('parameterize').wrap: -> $, $, Mu:U \t {
        die "A typed pointer can only hold integers, numbers, strings, CStructs, CPointers or CArrays (not {t.^name})"
            unless t ~~ Int|Num|Bool || t === Str|void || t.REPR eq any <CStruct CUnion CPPStruct CPointer CArray>;
        my \typed := TypedPointer[t];
        typed.^inheritalize;
    }
}

augment class CArray {
    my role IntTypedCArray[::TValue] does Positional[TValue] is CArray is repr('CArray') is array_type(TValue) {
        multi method AT-POS(::?CLASS:D \arr: $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::p6box_i(nqp::atpos_i(nqp::decont(arr), nqp::unbox_i($pos.Int)))
                },
                STORE => method (int $v) {
                    nqp::bindpos_i(nqp::decont(arr), nqp::unbox_i($pos.Int), $v);
                    self
                }
        }
        multi method AT-POS(::?CLASS:D \arr: int $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::p6box_i(nqp::atpos_i(nqp::decont(arr), $pos))
                },
                STORE => method (int $v) {
                    nqp::bindpos_i(nqp::decont(arr), $pos, $v);
                    self
                }
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: int $pos, int $assignee) {
            nqp::bindpos_i(nqp::decont(arr), $pos, $assignee);
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: Int $pos, int $assignee) {
            nqp::bindpos_i(nqp::decont(arr), nqp::unbox_i($pos), $assignee);
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: Int $pos, Int $assignee) {
            nqp::bindpos_i(nqp::decont(arr), nqp::unbox_i($pos), nqp::unbox_i($assignee));
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: int $pos, Int $assignee) {
            nqp::bindpos_i(nqp::decont(arr), $pos, nqp::unbox_i($assignee));
        }
    }

    my role NumTypedCArray[::TValue] does Positional[TValue] is CArray is repr('CArray') is array_type(TValue) {
        multi method AT-POS(::?CLASS:D \arr: $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::p6box_n(nqp::atpos_n(nqp::decont(arr), nqp::unbox_i($pos.Int)))
                },
                STORE => method (num $v) {
                    nqp::bindpos_n(nqp::decont(arr), nqp::unbox_i($pos.Int), $v);
                    self
                }
        }
        multi method AT-POS(::?CLASS:D \arr: int $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::p6box_n(nqp::atpos_n(nqp::decont(arr), $pos))
                },
                STORE => method (num $v) {
                    nqp::bindpos_n(nqp::decont(arr), $pos, $v);
                    self
                }
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: int $pos, num $assignee) {
            nqp::bindpos_n(nqp::decont(arr), $pos, $assignee);
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: Int $pos, num $assignee) {
            nqp::bindpos_n(nqp::decont(arr), nqp::unbox_i($pos), $assignee);
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: Int $pos, Num $assignee) {
            nqp::bindpos_n(nqp::decont(arr), nqp::unbox_i($pos), nqp::unbox_n($assignee));
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: int $pos, Num $assignee) {
            nqp::bindpos_n(nqp::decont(arr), $pos, nqp::unbox_n($assignee));
        }
    }

    my role TypedCArray[::TValue] does Positional[TValue] is CArray is repr('CArray') is array_type(TValue) {
        multi method AT-POS(::?CLASS:D \arr: $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::atpos(nqp::decont(arr), nqp::unbox_i($pos.Int))
                },
                STORE => method ($v) {
                    nqp::bindpos(nqp::decont(arr), nqp::unbox_i($pos.Int), nqp::decont($v));
                    self
                }
        }
        multi method AT-POS(::?CLASS:D \arr: int $pos) is rw {
            Proxy.new:
                FETCH => method () {
                    nqp::atpos(nqp::decont(arr), $pos)
                },
                STORE => method ($v) {
                    nqp::bindpos(nqp::decont(arr), $pos, nqp::decont($v));
                    self
                }
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: int $pos, \assignee) {
            nqp::bindpos(nqp::decont(arr), $pos, nqp::decont(assignee));
        }
        multi method ASSIGN-POS(::?CLASS:D \arr: Int $pos, \assignee) {
            nqp::bindpos(nqp::decont(arr), nqp::unbox_i($pos), nqp::decont(assignee));
        }
    }

    CArray.HOW.^can('parameterize').wrap: -> $, $, Mu:U \t {
        my $typed;
        if t ~~ Int {
            $typed := IntTypedCArray[t.WHAT];
        }
        elsif t ~~ Num {
            $typed := NumTypedCArray[t.WHAT];
        }
        else {
            die "A C array can only hold integers, numbers, strings, CStructs, CPointers or CArrays (not {t.^name})"
                unless t === Str || t.REPR eq 'CStruct' | 'CPPStruct' | 'CUnion' | 'CPointer' | 'CArray';
            $typed := TypedCArray[t];
        }
        $typed.^inheritalize();
    }
}
