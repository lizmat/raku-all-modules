use lib 'lib';
use Digest::FNV;
use DB::ORM::Quicky;

my DB::ORM::Quicky $orm .=new;

my @numbers = 0 .. 100000;
my @keys    = qw<org user msg agreement>;

my %result;

$orm.connect(
  driver  => 'Pg',
  options => {
    user     => 'fnv_coll',
    database => 'fnv_coll',
  },
);

'generating hashes'.say;
for @numbers -> $n {
  say 'starting on '~$n
    if $n %% 10000;
  for @keys -> $k {
    my $r = $orm.create('fnv_values');
    $r.set({
      fnv_key   => "$k$n",
      fnv1a_val => 'f1a:'~fnv1a("$k$n"),
      fnv1_val  => 'f1:'~fnv1("$k$n"),
    });
    $r.save;
  }
}

'looking for collisions, this will take a while'.say;
die 'ded';
%result.keys.race.map({
  my $k = $_;
  "reviewing $k".say;
  %result{$k}.keys.race.map({
    my $n = $_;
    %result.keys.race.map({
      my $k2 = $_;
      %result{$k2}.keys.race.map({
        my $n2 = $_;
        "found duplicate $k$n and $k2$n2".say
          if    %result{$k}{$n} eq %result{$k2}{$n2}
             && "$k$n" ne "$k2$n2";
      });
    });
  });
});


