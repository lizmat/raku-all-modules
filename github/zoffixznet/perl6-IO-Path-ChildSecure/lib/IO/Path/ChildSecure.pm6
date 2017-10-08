sub child-secure (IO::Path:D \SELF, \child) is export {
    use MONKEY-GUTS;
    # The goal of this method is to guarantee the resultant child path is
    # inside the invocant. We resolve the path completely, so for that to
    # happen, the kid cannot be inside some currently non-existent dirs, so
    # this method will fail with X::IO::Resolve in those cases. To find out
    # if the kid is in fact a kid, we fully-resolve the kid and the
    # invocant. Then, we append a dir separator to invocant's .absolute and
    # check if the kid's .absolute starts with that string.
    nqp::if(
      nqp::istype((my $kid := SELF.child(child).resolve: :completely),
        Failure),
      $kid, # we failed to resolve the kid, return the Failure
      nqp::if(
        nqp::istype((my $res-self := SELF.resolve: :completely), Failure),
        $res-self, # failed to resolve invocant, return the Failure
        nqp::if(
          nqp::iseq_s(
            ($_ := nqp::concat($res-self.absolute, SELF.SPEC.dir-sep)),
            nqp::substr($kid.absolute, 0, nqp::chars($_))),
          $kid, # kid appears to be kid-proper; return it. Otherwise fail
          fail X::IO::NotAChild.new:
            :path($res-self.absolute), :child($kid.absolute))))
}
