unit role DB::Xoos::Searchable;

has Bool $!inflate = True;
has $!options = {};
has $!filter  = {};

multi submethod BUILD (Bool :$!inflate = True, :$!options = {}, :$!filter = {}) {
  my $searchable = "DB::Xoos::{self.driver}::Searchable";
  my $req = (try require ::($searchable)) === Nil;
  die "Unable to find $searchable or there was a problem loading it"
    if $req;
  self does ::($searchable) unless self ~~ ::($searchable);

  callsame;
}

method !filter  { $!filter;  }
method !options { $!options; }
method !inflate { $!inflate; }

method !set-filter(%filter)   { $!filter = %filter;   self; }
method !set-options(%options) { $!options = %options; self; }
method !set-inflate($inflate) { $!inflate = $inflate; self; }
