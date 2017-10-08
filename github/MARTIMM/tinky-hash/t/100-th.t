use v6.c;
use Test;
use Tinky::Hash;

#-------------------------------------------------------------------------------
subtest 'instantiate', {

  my Tinky::Hash $th .= new;
  is $th.^name, 'Tinky::Hash', 'type ok';
  ok $th.defined, 'object defined';
}

#-------------------------------------------------------------------------------
subtest 'setup', {

  my Tinky::Hash $th .= new(
    :config( %(
        :states([< a b c>]),
        :transitions( {
            :ab( { :from<a>, :to<b>}),
            :ba( { :from<b>, :to<a>}),
            :bc( { :from<b>, :to<c>}),
            :ca( { :from<c>, :to<a>}),
            :cb( { :from<c>, :to<b>}),
          }
        ),
        :workflow( {
            :name<wf1>,
            :initial-state<a>,
          }
        ),
      )
    )
  );

  diag 'Workflow wf1';
  $th.workflow('wf1');
  is $th.state.name, 'a', "starting state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<b>,), "next: {$th.next-states>>.name}";

  $th.go-state('b');
  is $th.state.name, 'b', "starting state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, <a c>, "next: {$th.next-states>>.name}";
}

#-------------------------------------------------------------------------------
subtest 'class setup', {

  class C1th is Tinky::Hash {

    submethod BUILD ( ) {

      self.from-hash(
        :config( %(
            :states([< a c q>]),
            :transitions( {
                :aq( { :from<a>, :to<q>}),
                :qa( { :from<q>, :to<a>}),
                :qc( { :from<q>, :to<c>}),
                :ca( { :from<c>, :to<a>}),
                :cq( { :from<c>, :to<q>}),
              }
            ),
            :workflow( {
                :name<wf2>,
                :initial-state<a>,
              }
            ),
          )
        )
      );
    }
  }

  my C1th $th .= new;

  diag 'Workflow wf1';
  $th.workflow('wf1');
  is $th.state.name, 'a', "starting state is '$th.state.name()'";
  is-deeply $th.next-states>>.name, [<b>], "next: {$th.next-states>>.name}";

  diag 'Workflow wf2';
  $th.workflow('wf2');
  $th.go-state('q');
  is $th.state.name, 'q', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, <a c>, "next: {$th.next-states>>.name}";

  diag 'Try workflow wf1';
  dies-ok {$th.workflow('wf1')},
          'Cannot switch when state is not known in other workflow, no next states';

  $th.go-state('c');
  is $th.state.name, 'c', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, <a q>, "next: {$th.next-states>>.name}";

  diag 'Workflow wf1';
  $th.workflow('wf1');
  is $th.state.name, 'c', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, <a b>, "next: {$th.next-states>>.name}";
}

#-------------------------------------------------------------------------------
subtest 'global transition taps', {

  class C2th is Tinky::Hash {

    submethod BUILD ( ) {

      self.from-hash(
        :config( %(
            :states([< a q>]),
            :transitions( {
                :aq( { :from<a>, :to<q>}),
                :qa( { :from<q>, :to<a>}),
              }
            ),
            :workflow( { :name<wf3>, :initial-state<a>}),
            :taps( { :transitions-global<tr-method1>}),
          )
        )
      );
    }

    method tr-method1 ( $object, Tinky::Transition $trans ) {
      say "global transition '", $object.^name, ', ', self.^name(),
          "', '$trans.from.name()' ===>> '$trans.to.name()'";
    }
  }

  my C2th $th .= new;

  diag 'Workflow wf3';
  $th.workflow('wf3');
  is $th.state.name, 'a', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<q>,),
            "next: {$th.next-states>>.name}";

  $th.go-state('q');
  is $th.state.name, 'q', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<a>,),
            "next: {$th.next-states>>.name}";
}

#-------------------------------------------------------------------------------
subtest 'specific transition taps', {

  class C3th is Tinky::Hash {

    submethod BUILD ( ) {

      self.from-hash(
        :config( {
            :states([< a z q>]),
            :transitions( {
                :az( { :from<a>, :to<z>}),
                :za( { :from<z>, :to<a>}),
                :zq( { :from<z>, :to<q>}),
                :qa( { :from<q>, :to<a>}),
              }
            ),
            :workflow( { :name<wf4>, :initial-state<a>}),
            :taps( {
                :transitions( { :zq<tr-zq>}),
                :states( { :q( { :enter<enter-q>})})
              }
            ),
          }
        )
      );
    }

    method tr-zq ( $object, Tinky::Transition $trans, Str :$transit ) {
      say "specifig transition $transit '", $object.^name, ', ', self.^name,
          "' '$trans.from.name()' ===>> '$trans.to.name()'";
      is $trans.from.name, 'z', "Comes from 'z'";
      is $trans.to.name, 'q', "Goes to 'q'";
    }

    method enter-q ( $object, Str :$state, EventType :$event) {
      say "state enter event: enter q in ", $object.^name, ', ', self.^name;
      is $state, 'q', 'state is q';
      is $event, Enter, 'event is Enter';
    }
  }

  my C3th $th .= new;

  diag 'Workflow wf4';
  $th.workflow('wf4');
  is $th.state.name, 'a', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<z>,), "next: {$th.next-states>>.name}";

  $th.go-state('z');
  is $th.state.name, 'z', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<a q>), "next: {$th.next-states>>.name}";

  $th.go-state('q');
  diag 'Workflow wf3, transition supply from previous workflow';
  $th.workflow('wf3');
  $th.go-state('a');
}

#-------------------------------------------------------------------------------
subtest 'state taps', {

  class C4th is Tinky::Hash {

    submethod BUILD ( ) {

      self.from-hash(
        :config( {
            :states([< a z>]),
            :transitions( {
                :az( { :from<a>, :to<z>}),
                :za( { :from<z>, :to<a>}),
              }
            ),
            :workflow( { :name<wf5>, :initial-state<a>}),
            :taps( {
                :states( {
                    :a( { :leave<leave-a>}),
                    :z( { :enter<enter-z>})
                  }
                ),
              }
            ),
          }
        )
      );
    }

    method leave-a ( $object ) {
      say "state leave event: left  a in ", $object.^name, ', ', self.^name;
    }

    method enter-z ( $object ) {
      say "state enter event: enter z in ", $object.^name, ', ', self.^name;
    }
  }

  my C4th $th .= new;

  diag 'Workflow wf5';
  $th.workflow('wf5');
  is $th.state.name, 'a', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<z>,), "next: {$th.next-states>>.name}";

  $th.go-state('z');
  is $th.state.name, 'z', "state is '$th.state.name()'";
  is-deeply $th.next-states>>.name.sort, (<a>,), "next: {$th.next-states>>.name}";

  diag 'Workflow wf4';
  $th.workflow('wf4');
  $th.go-state('q');
}

#-------------------------------------------------------------------------------
done-testing;
