use v6;
use Pod::Tester;
use Pod::Coverage::Result;
use Pod::Coverage::PodEgg;
#| I<Sometimes any block pod no matter what contains may be fine>
#| checks only if provided files return any result of C<perl6 --pod>
unit class Pod::Coverage::Anypod does Pod::Tester;

has $.path;
has $.packageStr;

method check {
    self!file-haspod;
}

#| Checks if module file contains at least any line of pod
method !file-haspod {
    my $r =  new-result(packagename => $!packageStr, path => $!path);
    my $egg = Pod::Coverage::PodEgg.new(orig => $!path);
    $r.is_ok = any( has-pod($egg.orig), has-pod($egg.pod), has-pod($egg.pod6)).Bool;
  
  @.results.push($r)
}


sub has-pod($path) returns Bool {
    #dd qqx/$*EXECUTABLE-NAME --doc $path/.lines.elems;
    $path.IO ~~ :f and qqx/$*EXECUTABLE-NAME --doc $path/.lines.elems.Bool;
}




