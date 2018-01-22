use v6.c;
unit module P5tie:ver<0.0.7>;  # must be different from "tie"

sub tie(\subject, $class, *@extra is raw) is export {

    # get the stash for easier lookups, and the name of the subject
    my $stash := $class.WHO;
    my $name  := subject.VAR.name;

    # fetch API sub / method from given class
    sub check($method, :$test) is raw {
        if $stash{'&' ~ $method} // $class.can($method)[0] -> &code {
            &code
        }
        elsif $test {
            Nil
        }
        else {
            die "Could not find '$method' in '{$class.^name}'";
        }
    }

    # generic prefix for .perl methods
    sub perl-preamble(--> Str:D) { "tie my $name, {$class.^name}; $name = " }

    # handle tieing a scalar
    if check('TIESCALAR', :test) -> &tiescalar {
        my \this    := tiescalar($class, |@extra);
        my &fetch   := check('FETCH');
        my &store   := check('STORE');
        my &untie   := check('UNTIE');
        my &destroy := check('DESTROY');

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the Proxy that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY($name,Proxy.new(
          FETCH => -> $       { fetch(this)                  },
          STORE => -> $, \val { store(this,val); fetch(this) }
        ));

        this
    }

    # handle tieing an array
    elsif check('TIEARRAY', :test) -> &tiearray {
        my \this := tiearray($class, |@extra);

        my class TiedArray does Iterable {
            has $.tied;
            has &!FETCH;
            has &!STORE;
            has &!FETCHSIZE;
            has &!STORESIZE;
            has &!EXTEND;
            has &!EXISTS;
            has &!DELETE;
            has &!CLEAR;
            has &!PUSH;
            has &!POP;
            has &!SHIFT;
            has &!UNSHIFT;
            has &!SPLICE;
            has &!UNTIE;
            has &!DESTROY;

            method new(\tied) { self.CREATE!SET-SELF(tied) }
            method !SET-SELF($!tied) {
                &!FETCH     := check('FETCH');
                &!STORE     := check('STORE');
                &!FETCHSIZE := check('FETCHSIZE');
                &!STORESIZE := check('STORESIZE');
                &!EXTEND    := check('EXTEND');
                &!EXISTS    := check('EXISTS');
                &!DELETE    := check('DELETE');
                &!CLEAR     := check('CLEAR');
                &!PUSH      := check('PUSH');
                &!POP       := check('POP');
                &!SHIFT     := check('SHIFT');
                &!UNSHIFT   := check('UNSHIFT');
                &!SPLICE    := check('SPLICE');
                &!UNTIE     := check('UNTIE');
                &!DESTROY   := check('DESTROY');
                self
            }

            method AT-POS($index) is raw {
                Proxy.new(
                  FETCH => -> $       { &!FETCH($!tied,$index)     },
                  STORE => -> $, \val { &!STORE($!tied,$index,val) }
                )
            }
            method ASSIGN-POS($index,\value) is raw {
                &!STORE($!tied,$index,value)
            }
            method BIND-POS($) {
                die "Cannot bind to tied Array, as Perl 5 doesn't know binding"
            }
            method EXISTS-POS($index) { &!EXISTS($!tied,$index) }
            method DELETE-POS($index) { &!DELETE($!tied,$index) }

            method elems(--> Int:D)   { &!FETCHSIZE($!tied)     }
            method Bool(--> Bool:D)   { ?&!FETCHSIZE($!tied)    }
            method Numeric(--> Int:D) { &!FETCHSIZE($!tied)     }

            method pop()   is raw { &!POP($!tied)   }
            method shift() is raw { &!SHIFT($!tied) }

            method push(\value) {
                &!PUSH($!tied,value);
                &!FETCHSIZE($!tied)
            }
            method unshift(\value) {
                &!UNSHIFT($!tied,value);
                &!FETCHSIZE($!tied)
            }
            method splice(*@args is raw) { &!SPLICE($!tied,|@args) }

            method STORE(*@args) {
                &!CLEAR($!tied);
                for @args.kv -> $index, \value {
                    &!STORE($!tied,$index,value)
                }
                self
            }

            method iterator() {
                class :: does Iterator {
                    has $!tied;
                    has &!FETCH;
                    has &!STORE;
                    has int $!elems;
                    has int $!index;

                    method new(\t,\fe,\st,\el) {
                        self.CREATE!SET-SELF(t,fe,st,el)
                    }
                    method !SET-SELF($!tied,&!FETCH,&!STORE,$!elems) {
                        $!index = -1;
                        self
                    }

                    method pull-one() is raw {
                        ++$!index < $!elems
                          ?? Proxy.new(
                               FETCH => -> $       { &!FETCH($!tied,$!index)     },
                               STORE => -> $, \val { &!STORE($!tied,$!index,val) }
                             )
                          !! IterationEnd
                    }
                }.new($!tied,&!FETCH,&!STORE,&!FETCHSIZE(self))
            }

            method join($delimiter = "" --> Str:D) {
                my str @strings;
                @strings.push(&!FETCH($!tied,$_).Str) for ^&!FETCHSIZE($!tied);
                @strings.join($delimiter)
            }

            method Str( --> Str:D) { self.join(" ") }
            method gist(--> Str:D) { self.join(" ") }

            method perl(--> Str:D) {
                my str @strings;
                @strings.push(&!FETCH($!tied,$_).perl) for ^&!FETCHSIZE($!tied);
                perl-preamble() ~ @strings.join(',') ~ ';'
            }

            method DESTROY() { &!DESTROY($!tied) }

            method untie() { ::($!tied.^name ~ '::&UNTIE')($!tied) }
        }

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the object that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY($name,TiedArray.new(this));

        this
    }

    # handle tieing a hash
    elsif check('TIEHASH', :test) -> &tiehash {
        my \this := tiehash($class, |@extra);

        my class TiedHash does Associative {
            has $.tied;
            has &!FETCH;
            has &!STORE;
            has &!DELETE;
            has &!CLEAR;
            has &!EXISTS;
            has &!FIRSTKEY;
            has &!NEXTKEY;
            has &!SCALAR;
            has &!UNTIE;
            has &!DESTROY;

            method new(\tied) { self.CREATE!SET-SELF(tied) }
            method !SET-SELF($!tied) {
                &!FETCH     := check('FETCH');
                &!STORE     := check('STORE');
                &!DELETE    := check('DELETE');
                &!CLEAR     := check('CLEAR');
                &!EXISTS    := check('EXISTS');
                &!FIRSTKEY  := check('FIRSTKEY');
                &!NEXTKEY   := check('NEXTKEY');
                &!SCALAR    := check('SCALAR');
                &!UNTIE     := check('UNTIE');
                &!DESTROY   := check('DESTROY');
                self
            }

            method AT-KEY($key) is raw {
                Proxy.new(
                  FETCH => -> $       { &!FETCH($!tied,$key)     },
                  STORE => -> $, \val { &!STORE($!tied,$key,val) }
                )
            }
            method ASSIGN-KEY($key,\value) is raw { &!STORE($!tied,$key,value) }
            method BIND-KEY($) {
                die "Cannot bind to tied Hash, as Perl 5 doesn't know binding"
            }
            method DELETE-KEY($key) { &!DELETE($!tied,$key) }
            method EXISTS-KEY($key) { &!EXISTS($!tied,$key) }

            method STORE(*@args) {
                &!CLEAR($!tied);
                for @args -> $key, \value {
                    &!STORE($!tied,$key,value)
                }
                self
            }

            method iterator(
              &mapper = -> \key { Pair.new(key,&!FETCH($!tied,key)) }
            ) {
                class :: does Iterator {
                    has $!tied;
                    has &!FIRSTKEY;
                    has &!NEXTKEY;
                    has &!mapper;
                    has $!lastkey;

                    method new(\t,\fk,\nk,\ma) {
                        self.CREATE!SET-SELF(t,fk,nk,ma)
                    }
                    method !SET-SELF($!tied,&!FIRSTKEY,&!NEXTKEY,&!mapper) {
                        $!lastkey := Mu;
                        self
                    }

                    method pull-one() is raw {
                        use fatal;
                        if $!lastkey =:= Mu {       # first time
                            ($!lastkey := &!FIRSTKEY($!tied)) =:= Nil
                              ?? IterationEnd         # empty hash
                              !! &!mapper($!lastkey)  # first element
                        }
                        elsif $!lastkey =:= Nil {   # exhausted before
                            IterationEnd
                        }
                        else {                      # not exhausted yet
                            ($!lastkey := &!NEXTKEY($!tied,$!lastkey)) =:= Nil
                              ?? IterationEnd         # exhausted now
                              !! &!mapper($!lastkey)  # next element
                        }
                    }
                }.new($!tied,&!FIRSTKEY,&!NEXTKEY,&mapper)
            }

            method elems(--> Int:D)  {
                my int $elems;
                self.iterator({ ++$elems }).sink-all;
                $elems
            }
            method Bool(--> Bool:D) { &!FIRSTKEY($!tied) !=== Nil }
            method Numeric(--> Int:D) { self.elems }

            method pairs()  { Seq.new(self.iterator) }
            method keys()   { Seq.new(self.iterator: { $_ } ) }
            method values() { Seq.new(self.iterator: { &!FETCH($!tied,$_) } ) }
            method antipairs() {
                Seq.new(self.iterator( { Pair.new(&!FETCH($!tied,$_),$_) } ))
            }

            method join($delimiter = "" --> Str:D) {
                my str @strings;
                self.iterator({ "$_\t&!FETCH($!tied,$_)" }).push-all(@strings);
                @strings.join($delimiter)
            }

            method Str( --> Str:D) { self.join("\n") }
            method gist(--> Str:D) { self.join(" ") }

            method perl(--> Str:D) {
                perl-preamble() ~ self.pairs.map( *.perl ).join(',') ~ ';'
            }

            method DESTROY() { &!DESTROY($!tied) }

            method untie() { ::($!tied.^name ~ '::&UNTIE')($!tied) }
        }

        # This is a bit fragile, but the only way to bind the replace the
        # original container given by the object that we need to actually
        # get the tied behaviour.
        CALLER::CALLER::.BIND-KEY($name,TiedHash.new(this));

        this
    }

    # handle tieing a handle
    elsif check('TIEHANDLE', :test) -> &tiehandle {
        X::NYI.new(feature => "Tieing a file handle").throw
    }

    # sorry
    else {
        die "Not obvious which type of tie() is intended";
    }
}

sub tied(\this)  is export { this.tied }
sub untie(\this) is export { this.untie }

=begin pod

=head1 NAME

P5tie - Implement Perl 5's tie() built-in

=head1 SYNOPSIS

  use P5tie; # exports tie(), tied() and untie()

  tie my $s, Tie::AsScalar;
  tie my @a, Tie::AsArray;
  tie my %h, Tie::AsHash;

  $object = tied $s;
  untie $s;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<tie> of Perl 5 as closely as
possible.  Please note that there are usually better ways attaching special
functionality to arrays, hashes and scalars in Perl 6 than using C<tie>.  Please
see the documentation on
L<Custom Types|https://docs.perl6.org/language/subscripts#Custom_types> for more
information to handling the needs that Perl 5's C<tie> fulfills in a more
efficient way in Perl 6.

=head1 PORTING CAVEATS

=head2 Subs versus Methods

In Rakudo Perl 6, the special methods of the tieing class, can be implemented
as Perl 6 C<method>s, or they can be implemented as C<our sub>s, both are
perfectly acceptable.  They can even be mixed, if necessary.  But note that
if you're depending on subclassing, that you must change the C<package> to a
C<class> to make things work.

=head2 Untieing

Because Rakudo Perl 6 does not have the concept of magic that can be added or
removed, it is B<not> possible to C<untie> a variable.  Note that the associated
C<UNTIE> sub/method B<will> be called, so that any resources can be freed.

Potentially it would be possible to actually have any subsequent accesses to the
tied variable throw an exception: perhaps it will at some point.

=head2 Scalar variable tying versus Proxy

Because tying a scalar in Rakudo Perl 6 B<must> be implemented using a C<Proxy>,
and it is currently not possible to mix in any additional behaviour into a
C<Proxy>, it is alas impossible to implement C<UNTIE> and C<DESTROY> for tied
scalars at this point in time.  Please note that C<UNTIE> and C<DESTROY> B<are>
supported for tied arrays and hashes.

=head2 Tieing a file handle

Tieing a file handle is not yet implemented at this time.  Mainly because I don't
grok yet how to do that.  As usual, patches and Pull Requests are welcome!

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5tie . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
