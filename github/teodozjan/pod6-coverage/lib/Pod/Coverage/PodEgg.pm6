use v6;

#| provides various files that pod may be stored in
#| for module provided as C<$orig>
unit class Pod::Coverage::PodEgg;

has $.orig;

method pod  {$!orig.subst(/\.pm[6]*$/, '.pod');}
method pod6 {$!orig.subst(/\.pm[6]*$/, '.pod6')};

method list {
    gather {
        take $!orig;
        take self.pod if self.pod.IO ~~ :f;
        take self.pod6 if self.pod6.IO ~~ :f
    }
}
