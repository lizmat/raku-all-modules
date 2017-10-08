use v6;
use lib 'lib';

use Test::Lab;
use Test::Lab::Experiment;

my %results;

class PartitionExperiment is Test::Lab::Experiment {
  method new($name) { PartitionExperiment.bless(:$name) }
  method is-enabled { True }
  method publish($result) {
    %results{$result.control.name}.push: $result.control.duration;
    for $result.candidates.sort({ $^a.name cmp $^b.name }) {
      %results{$_.name}.push: $_.duration
    }
  }
}

Test::Lab::<$experiment-class> = PartitionExperiment;

sub head-tail(@ls) {
  lab 'head-tail-partitions', -> $e {
    $e.use: {
      (
        (('a'), ('b', 'c', 'd', 'e')),
        (('a', 'b'), ('c', 'd', 'e')),
        (('a', 'b', 'c'), ('d', 'e')),
        (('a', 'b', 'c', 'd'), ('e'))
      )
    }
    $e.try: {
      (@ls[^$_, $_..*] for 1..^@ls)
    }, :name<a>;
    $e.try: {
      (1..^@ls).map: {@ls[^$_, $_..*]}
    }, :name<b>;
    $e.try: {
      (@ls.rotor($_, ∞, :partial) for 1..^@ls)
    }, :name<c>;
    $e.try: {
      @ls[0..*-2].keys.map: {@ls[0..$_, $_^..*]} # same as b
    }, :name<d>;
    $e.try: {
      (1..^@ls).map: {@ls.rotor: $_, ∞, :partial}
    }, :name<e>;
    $e.try: {
      (@ls.head($_), @ls.tail(@ls - $_) for 1..^@ls)
    }, :name<f>;
    $e.try: {
      (|@ls.rotor: $_, @ls - $_ for 1..^@ls).rotor: 2
    }, :name<g>;
    $e.try: {
      @ls.keys.map: {@ls[0..$_, $_^..*] if $_ < @ls.end}
    }, :name<h>;
    $e.try: {
      @ls.keys.map: {@ls.head($_), @ls.tail(@ls - $_) if $_}
    }, :name<i>;
    $e.try: {
      @ls.rotor(|(1..^@ls Z (@ls-1…0) »=>» -@ls), ∞).rotor: 2
    }, :name<j>;
    $e.try: {
      ([\,] @ls) Z (([\,] @ls[1..*].reverse)».reverse).reverse
    }, :name<k>;
  }
}

my @ls = 'a'..'e';
my @parts;
for ^100 {
  @parts = head-tail(@ls);
}

for %results.pairs.sort({ $^a.value cmp $^b.value }) -> $candidate {
  my $avg-dur = $candidate.value.reduce(*+*)/$candidate.value.elems;
  say "{$candidate.key}\t$avg-dur"
}

=begin Result
control	0.00207062862973851
h	0.00188188188188188
b	0.00163588661289833
e	0.00178719909623425
i	0.00160390886401405
c	0.0021093181966983
d	0.00243906331220745
f	0.0021822786716838
k	0.00340367242430569
j	0.00580621503235941
a	0.00738912585363849
g	0.00756488437100402
=end Result
