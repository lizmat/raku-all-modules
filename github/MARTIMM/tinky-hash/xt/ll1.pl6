use v6.c;

use Test;
use Tinky;

my $st-a1 = Tinky::State.new(:name<a>);
my $st-b1 = Tinky::State.new(:name<b>);
my $st-c1 = Tinky::State.new(:name<c>);

my $t-ac1 = Tinky::Transition.new( :name<ac>, :from($st-a1), :to($st-c1));
my $t-ab1 = Tinky::Transition.new( :name<ab>, :from($st-a1), :to($st-b1));
my $t-ca1 = Tinky::Transition.new( :name<ca>, :from($st-c1), :to($st-a1));

my $wf1 = Tinky::Workflow.new(
  :name<wf1>,
  :states( $st-a1, $st-b1, $st-c1),
  :transitions( $t-ac1, $t-ab1, $t-ca1),
  :initial-state($st-c1)
);

my $st-a2 = Tinky::State.new(:name<a>);
my $st-b2 = Tinky::State.new(:name<b>);
my $st-p2 = Tinky::State.new(:name<p>);

my $t-ap2 = Tinky::Transition.new( :name<ap>, :from($st-a2), :to($st-p2));
my $t-ab2 = Tinky::Transition.new( :name<ab>, :from($st-a2), :to($st-b2));
my $t-pa2 = Tinky::Transition.new( :name<pa>, :from($st-p2), :to($st-a2));

my $wf2 = Tinky::Workflow.new(
  :name<wf2>,
  :states( $st-a2, $st-b2, $st-p2),
  :transitions( $t-ap2, $t-ab2, $t-pa2),
  :initial-state($st-a2)
);

#-------------------------------------------------------------------------------
subtest 'test double workflow', {

  class Co does Tinky::Object { }
  
  my Co $th1 .= new;

  diag 'Workflow wf1';
  $th1.apply-workflow($wf1);
  is $th1.state.name, 'c', "starting state is '$th1.state.name()'";
  is-deeply $th1.next-states>>.name.sort, (<a>,),
            "next: {$th1.next-states>>.name}";

  try-run {$th1.state = $st-c1;}, /:s No Transition for \'c\' to \'c\'/;

  diag 'Workflow wf2';
  $th1.apply-workflow($wf2);
  try-run {$th1.state = $st-p2}, /:s No Transition for \'c\' to \'p\'/;

  try-run {$th1.apply-workflow($wf1)},
  /:s Cannot switch workflow. State \'p\' not found in workflow \'wf1\'/;
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
