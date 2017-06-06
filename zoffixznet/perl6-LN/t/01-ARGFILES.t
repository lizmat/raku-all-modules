use lib <lib>;
use Testo;

plan 2;

my \a = ('-Ilib', |('-I' «~« $*REPO.repo-chain.map: *.path-spec), |<-MLN -e>);

group '.ln method' => 3 => {
    is-run $*EXECUTABLE, :args[|a, ｢print $*ARGFILES.ln｣],
      :out<0>, '.ln of $*ARGFILES is zero before start';

    is-run $*EXECUTABLE, :args[|a, ｢
          with $*ARGFILES {
              .get.say;
              .ln.say;
              .get.say;
              .ln.say;
              .get.say;
              .ln.say;
              .get.say;
              .ln.say;
              .get.say;
              .ln.say;
          }
      ｣], :in("foo\nbar"), :out("foo\n1\nbar\n2\nNil\n0\nNil\n0\nNil\n0\n"),
      '.get works';

    is-run $*EXECUTABLE, :args[|a, ｢
          for lines() {
              .say;
              $*ARGFILES.ln.say;
          }
          $*ARGFILES.ln.say;
      ｣], :in("foo\nbar"), :out("foo\n1\nbar\n2\n0\n"), '.lines works';
}

group '$*LN var' => 3 => {
    is-run $*EXECUTABLE, :args[|a, ｢print $*LN｣],
      :out<0>, '$*LN is zero before start';

    is-run $*EXECUTABLE, :args[|a, ｢
          with $*ARGFILES {
              .get.say;
              $*LN.say;
              .get.say;
              $*LN.say;
              .get.say;
              $*LN.say;
              .get.say;
              $*LN.say;
              .get.say;
              $*LN.say;
          }
      ｣], :in("foo\nbar"), :out("foo\n1\nbar\n2\nNil\n0\nNil\n0\nNil\n0\n"),
      '.get works';

    is-run $*EXECUTABLE, :args[|a, ｢
          with $*ARGFILES {
              for .lines {
                  .say;
                  $*LN.say;
              }
              $*LN.say;
          }
      ｣], :in("foo\nbar"), :out("foo\n1\nbar\n2\n0\n"), '.lines works';
}
