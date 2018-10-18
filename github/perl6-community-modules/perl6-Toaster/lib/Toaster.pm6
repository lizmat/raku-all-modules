use RakudoPrereq v2017.05.380.*,
    'Toaster.pm6 module requires Rakudo v2017.06 or newer';

unit class Toaster;

use Proc::Q;
use JSON::Fast;
use Temp::Path;
use Terminal::ANSIColor;
use WhereList;
use WWW;

use Toaster::DB;

has $.db = Toaster::DB.new;

constant INSTALL_TIMEOUT  = 10*60;
constant ECO_API          = 'https://modules.perl6.org/search.json';
constant RAKUDO_REPO      = 'https://github.com/rakudo/rakudo';
constant ZEF_REPO         = 'https://github.com/ugexe/zef';
constant RAKUDO_BUILD_DIR = 'build'.IO.mkdir.self;
constant BANNED_MODULES   = (
    # regex objects to regex over the name
    /« [
      |'November'
      |'HTTP::Server::Threaded'
      |'HTTP::Server::Async'
      |'MeCab'
      |'Time::Duration'
      |'Task::Galaxy'
      |'Uzu'
      |'IRC::Client'
      |'Log::Minimal'
      |'Toaster'
    ]»/,
);

my $batch = floor 1.3 * do with run 'lscpu', :out, :!err {
    .out.lines(:close).grep(*.contains: 'CPU(s)').head andthen .words.tail.Int
} || 8;


method toast-all ($commit = 'master', Bool :$no-build) {
    my @modules = jget(ECO_API)<dists>.map(*.<name>).sort
        .grep: *.match: BANNED_MODULES.none;
    say "About to toast {+@modules} modules";
    self.toast: @modules, $commit;
}
method toast (@modules, $commit = 'master', Bool :$no-build) {
    temp %*ENV;
    %*ENV<PATH> = self.build-rakudo: $commit, :$no-build;
    %*ENV<ALL_TESTING  NETWORK_TESTING  ONLINE_TESTING> = 1, 1, 1;
    say "Toasting with path %*ENV<PATH>";
    my $ver = shell(:out, :!err,
      ｢perl6 -e 'print $*PERL.compiler.version.Str'｣).out.slurp: :close;
    say "Toasting with version $ver";
    run <zef info Test>; # output some info that zef uses right perl6
    my $rakudo      = $ver.subst(:th(2..*), '.', '').split('g').tail;
    my $rakudo-long
    = $ver.subst(:th(2, 3), '.', '-').subst(:th(2..*), '.', '');

    sub toast-it (@modules) {
        my @fails;
        my $store = make-temp-dir;
        react whenever proc-q @modules.map({
            my $where = $store.add(.subst: :g, /\W/, '_').mkdir;
            «zef --/cached --debug install "$_" "--install-to=inst#$where"»
        }), :tags[@modules], :$batch, :timeout(INSTALL_TIMEOUT) {
            my ToastStatus $status = .killed
              ?? Kill !! .out.contains('FAIL') ?? Fail
                !! .exitcode == 0 ?? Succ !! Unkn;

            $!db.add: $rakudo, $rakudo-long,
                .tag, .err, .out, ~.exitcode, $status;
            say colored "Finished {.tag}: $status",
                <red green>[$status ~~ Succ];

            @fails.push: .tag unless $status ~~ Succ;
        }
        say "Run is done! Have {+@fails} non-succs";
        @fails;
    }
    toast-it toast-it @modules;
}

method build-rakudo (Str:D $commit = 'master', Bool :$no-build) {
    say $no-build ?? "Trying to use exisitng build for rakudo $commit"
                  !! "Starting to build rakudo $commit";
    indir RAKUDO_BUILD_DIR, {
        my $com-dir = $commit.subst: :g, /\W/, '_';
        unless $no-build {
            $ = run «rm -fr "$com-dir"»;
            run «git clone "{RAKUDO_REPO}" "$com-dir"»;
        }
        indir $*CWD.add($com-dir), {
            unless $no-build {
                run «git checkout "$commit"»;
                say "Checkout done";
                run «perl Configure.pl --gen-moar --gen-nqp --backends=moar»;
                run «make»;
                run «make install»;
                run «git clone "{ZEF_REPO}"»;
            }

            temp %*ENV;
            %*ENV<PATH> = $*CWD.add('install/bin').absolute ~ ":%*ENV<PATH>";
            $no-build || indir $*CWD.add('zef'), { run «perl6 -Ilib bin/zef install . » }
            %*ENV<PATH> = $*CWD.add('install/share/perl6/site/bin')
              .absolute ~ ":%*ENV<PATH>";

            # Turn off auto update for p6c
            run «zef update»;
            given run(«zef --help», :err).err.slurp(:close)
              .lines.grep(*.starts-with: 'CONFIGURATION')
              .head.words.tail.trim.IO
            {
                my $j = from-json .slurp;
                for |$j<Repository> {
                    next unless .<short-name> eq 'p6c'|'cpan';
                    .<options><auto-update> = 0;
                }
                .spurt: to-json $j;
            }

            %*ENV<PATH>
        }
    }
}
