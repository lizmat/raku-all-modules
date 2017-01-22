use v6.c;
use Test;
use Tinky::Hash;

my Tinky::Hash $th;

#-------------------------------------------------------------------------------
subtest 'configuration errors', {

  try-cfg Any, /:s Type check failed in binding/;
  try-cfg {}, /:s No configuration provided/;
  try-cfg {:states([])}, /:s No states defined/;
  try-cfg {:states([< a b c>])}, /:s No transitions defined/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :aq( { :from<a>, :to<q>}),}),
  },
  /:s To\-state \'q\' not defined in states in transition \'aq\'/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
  },
  /:s Workflow is not defined/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<z>})
  },
  /:s Initial state \'z\' in workflow \'wf1\' is not defined/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<c>}),
    :taps( { :transitions-global<m1>}),
  },
  /:s Global transition method \'m1\' not found in Tinky\:\:Hash/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<a>}),
    :taps( { :transitions( { :zq<tr-zq>})})
  },
  /:s Transition name \'zq\' not defined in transitions/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<a>}),
    :taps( { :transitions( { :ac<m2>})})
  },
  /:s Specific transition method \'m2\' not found in Tinky\:\:Hash/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<a>}),
    :taps( { :states( { :x( { :leave<m3>})})})
  },
  /:s State \'x\' in states tap not defined/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<a>}),
    :taps( { :states( { :c( { :leave<m3>})})})
  },
  /:s State leave method \'m3\' not found in Tinky\:\:Hash/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf1>, :initial-state<a>}),
    :taps( { :states( { :c( { :enter<m4>})})})
  },
  /:s State enter method \'m4\' not found in Tinky\:\:Hash/;
}

#-------------------------------------------------------------------------------
subtest 'run errors', {

  class C1 is Tinky::Hash {
    submethod BUILD ( ) {
      self.from-hash(
        :config( {
            :states([< a b c>]),
            :transitions( {
                :ac( { :from<a>, :to<c>}),
                :ab( { :from<a>, :to<b>}),
                :ca( { :from<c>, :to<a>}),
              }
            ),
            :workflow( {
                :name<wf1>,
                :initial-state<c>,
              }
            )
          }
        )
      );

      self.from-hash(
        :config( {
            :states([< a b p>]),
            :transitions( {
                :ap( { :from<a>, :to<p>}),
                :ab( { :from<a>, :to<b>}),
                :pa( { :from<p>, :to<a>}),
              }
            ),
            :workflow( {
                :name<wf2>,
                :initial-state<a>,
              }
            )
          }
        )
      );
    }
  }

  my C1 $th1 .= new;
  try-run {$th1.go-state('c');}, /:s No active workflow/;

  diag 'Workflow wf1';
  $th1.workflow('wf1');
  is $th1.state.name, 'c', "starting state is '$th1.state.name()'";
  is-deeply $th1.next-states>>.name.sort, (<a>,),
            "next: {$th1.next-states>>.name}";

  try-run {$th1.go-state('c');}, /:s No Transition for \'c\' to \'c\'/;
  try-run {$th1.workflow('wf3');}, /:s Workflow name \'wf3\' not defined/;

  try-cfg {
    :states([< a b c>]),
    :transitions( { :ac( { :from<a>, :to<c>}),}),
    :workflow( { :name<wf2>, :initial-state<a>}),
  },
  /:s Workflow \'wf2\' defined before/;

  $th1.go-state('a');

  diag 'Workflow wf2';
  $th1.workflow('wf2');
  $th1.go-state('p');

  try-run {$th1.workflow('wf1')},
  /:s Cannot switch workflow. State \'p\' not found in workflow \'wf1\'/;
}

#-------------------------------------------------------------------------------
sub try-cfg ( Any $config, Regex $error-text ) {

  try {
    $th .= new: :$config;

    CATCH {
      default {
        like .message, $error-text, .message;
      }
    }
  }
}

#-------------------------------------------------------------------------------
sub try-run ( Block $b, Regex $error-text ) {

  try {
    $b();

    CATCH {
      default {
        like .message, $error-text, .message;
      }
    }
  }
}

#-------------------------------------------------------------------------------
done-testing;
