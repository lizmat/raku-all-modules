use RakudoPrereq v2017.05.270.g.5227828.a.8,
    'IO::CatHandle::AutoLines module requires Rakudo v2017.06 or newer';
use MONKEY-GUTS;

role IO::CatHandle::AutoLines[Bool:D :$reset = True] {
    has Int:D $!ln = 0;
    has &!os-store;

    submethod TWEAK {
        self ~~ IO::CatHandle or die
          'IO::CatHandle::AutoLines can only be mixed into an IO::CatHandle';

        return unless $reset;

        sub reset { $!ln = 0 }
        with nqp::getattr(self, IO::CatHandle, '&!on-switch') -> $os {
            &!os-store := { reset; $os() }
        }
        else {
            &!os-store := &reset
        }

        nqp::bindattr(self, IO::CatHandle, '&!on-switch', Proxy.new:
          :FETCH{ &!os-store },
          :STORE(-> $, &code {
            &!os-store := do if &code {
              $_ = &code.count;
              when 2|Inf { -> \a, \b { reset; code a, b } }
              when 1     { -> \a     { reset; code a    } }
              when 0     { ->        { reset; code      } }
              die "Don't know how to handle on-switch of count $_."
                        ~ " Does IO::CatHandle even support that?"
            }
            else { { reset } }
          }));
    }
    method get {
        my \v = callsame;
        v === Nil ?? ($!ln = 0) !! $!ln++;
        v
    }
    method lines {
        Seq.new: my class :: does Iterator {
            has $!iter;
            has $!al;
            method !SET-SELF($!iter, $!al) { self }
            method new(\iter, \al) { self.bless!SET-SELF(iter, al) }
            method pull-one {
                my \v = $!iter.pull-one;
                v =:= IterationEnd ?? ($!al.ln = 0) !! $!al.ln++;
                v
            }
        }.new: callsame.iterator, self
    }
    method ln is rw {
        Proxy.new:
            :FETCH{ $!ln<> },
            :STORE(-> $, $!ln { $!ln }
        );
    }
}
