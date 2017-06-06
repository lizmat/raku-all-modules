use lib <lib>;
use Testo;
use Temp::Path;

plan 3;

my @FILES = make-temp-path :content("a\nb\n"    ),
            make-temp-path :content("c\nd\ne\nf"),
            make-temp-path :content("g\nh\ni"   );

is-run $*EXECUTABLE, :args[
    '-Ilib', |('-I' «~« $*REPO.repo-chain.map: *.path-spec), '-e', ｢
        use LN;
        for lines() {
            .say;
            $*ARGFILES.ln.say;
        }
        $*ARGFILES.ln.say;
        $*LN.say;
        IO::CatHandle.new does IO::CatHandle::AutoLines;
    ｣, |@FILES
], :out("a\n1\nb\n2\nc\n1\nd\n2\ne\n3\nf\n4\ng\n1\nh\n2\ni\n3\n0\n0\n"),
   'no args on use line';

is-run $*EXECUTABLE, :args[
    '-Ilib', |('-I' «~« $*REPO.repo-chain.map: *.path-spec), '-e', ｢
        use LN 'no-reset';
        for lines() {
            .say;
            $*ARGFILES.ln.say;
        }
        $*ARGFILES.ln.say;
        $*LN.say;
        IO::CatHandle.new does IO::CatHandle::AutoLines;
    ｣, |@FILES
], :out("a\n1\nb\n2\nc\n3\nd\n4\ne\n5\nf\n6\ng\n7\nh\n8\ni\n9\n0\n0\n"),
   'reset on use line';

is-run $*EXECUTABLE, :args[
    '-Ilib', |('-I' «~« $*REPO.repo-chain.map: *.path-spec), '-e', ｢
        use LN <resetdasdsa>;
    ｣, |@FILES
], :in("foo\nbar"), :err(/"Unknown option passed to LN module"/),
  'unknown options throw';
