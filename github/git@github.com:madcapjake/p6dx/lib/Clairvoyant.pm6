unit module Clairvoyant;

use File::Find;

sub modules(Str:D $dir) {
  find( :dir($dir), :type('file'), :name(rx!(\.p[m|l]?6?)$!) )».IO.flat.list;
}

sub local-modules {
  modules: '.';
}

sub meta-info($depth) is export {
  for [0..$depth] -> $i {
    if find(
      :dir('.' ~ '/..' x $i),
      :type('file'),
      :name( /META\.info|META6.json/ )
    ) -> $meta-file { return from-json slurp $meta-file }
  }
}

sub depended-modules($depth?) {
  meta-info($depth // 2)<depends>;
}

sub dep-mod-files() is export {
  gather {
    for |depended-modules() -> $short-name {
      my $cu = $*REPO.need(CompUnit::DependencySpecification.new(:$short-name));
      for $cu.distribution.provides {
        take $cu.repo.prefix.child('sources/' ~ $_.values[0]<pm><file>);
      }
    }
  }
}
