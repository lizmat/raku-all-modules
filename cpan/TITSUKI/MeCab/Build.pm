use LibraryMake;
use Zef::Fetch;
use Zef::Extract;

class Build {
    method build($workdir) {
        if $*DISTRO.is-win {
            die "Sorry, this binding doesn't support windows";
        }
        my $srcdir = "$workdir/src";
        my %vars = get-vars($workdir);
        %vars<mecab> = $*VM.platform-library-name('mecab'.IO);
        mkdir "$workdir/resources" unless "$workdir/resources".IO.e;
        mkdir "$workdir/resources/libraries" unless "$workdir/resources/libraries".IO.e;

        my $HOME = qq:x/echo \$HOME/.subst(/\s*/,"",:g);
        my $prefix = "$HOME/.p6mecab";
        self!install-mecab($workdir, $prefix);
        self!install-mecab-ipadic($workdir, $prefix);
        if "$workdir/resources/libraries/%vars<mecab>".IO.f {
            run 'rm', '-f', "$workdir/resources/libraries/%vars<mecab>";
        }
        run 'ln', '-s', "$prefix/lib/%vars<mecab>", "$workdir/resources/libraries/%vars<mecab>";
    }

    method !install-mecab($workdir, $prefix) {
        my $goback = $*CWD;
        my $srcdir = "$workdir/src";
        my %vars = get-vars($workdir);

        my @fetch-backends = [
            { module => "Zef::Service::Shell::wget" },
            { module => "Zef::Service::Shell::curl" },
        ];
        my $fetcher      = Zef::Fetch.new(:backends(@fetch-backends));
        my $uri          = 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE';
        my $archive-file = "mecab-0.996.tar.gz".IO.e
        ?? "mecab-0.996.tar.gz"
        !! $fetcher.fetch($uri, "mecab-0.996.tar.gz");

        my @extract-backends = [
            { module => "Zef::Service::Shell::tar" },
            { module => "Zef::Service::Shell::p5tar" },
        ];
        my $extractor   = Zef::Extract.new(:backends(@extract-backends));
        my $extract-dir = $extractor.extract($archive-file, $*CWD);
        if "mecab-0.996".IO.d {
            shell "patch -p1 mecab-0.996/src/mecab.h < $srcdir/mecab.h.patch";
            shell "patch -p1 mecab-0.996/src/libmecab.cpp < $srcdir/libmecab.cpp.patch";
            shell "patch -p1 mecab-0.996/src/tagger.cpp < $srcdir/tagger.cpp.patch";
        }
        chdir("mecab-0.996");
        shell("./configure --with-charset=utf8 --prefix=$prefix");
        shell("make");
        shell("make install");
        run 'echo', "$prefix/lib", '>', '/etc/ld.so.conf.d/mecab.conf';
        chdir($goback);
    }

    method !install-mecab-ipadic($workdir, $prefix) {
        my $goback = $*CWD;
        my $srcdir = "$workdir/src";
        my %vars = get-vars($workdir);

        my @fetch-backends = [
            { module => "Zef::Service::Shell::wget" },
            { module => "Zef::Service::Shell::curl" },
        ];
        my $fetcher      = Zef::Fetch.new(:backends(@fetch-backends));
        my $uri          = 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM';
        my $archive-file = "mecab-ipadic-2.7.0-20070801.tar.gz".IO.e
        ?? "mecab-ipadic-2.7.0-20070801.tar.gz"
        !! $fetcher.fetch($uri, "mecab-ipadic-2.7.0-20070801.tar.gz");

        my @extract-backends = [
            { module => "Zef::Service::Shell::tar" },
            { module => "Zef::Service::Shell::p5tar" },
        ];
        my $extractor   = Zef::Extract.new(:backends(@extract-backends));
        my $extract-dir = $archive-file.IO.basename.subst(/\.tar\.gz/, '').IO.e
        ?? $archive-file.IO.basename.subst(/\.tar\.gz/, '').IO
        !! $extractor.extract($archive-file, $*CWD);

        chdir("mecab-ipadic-2.7.0-20070801");
        shell("./configure --with-charset=utf8 --prefix=$prefix --with-mecab-config=$prefix/bin/mecab-config");
        shell("make");
        shell("make install");
        chdir($goback);
    }

    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
