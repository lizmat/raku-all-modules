

use Archive::Libarchive;
use CPAN::Uploader::Tiny;
use META6;
use Oyatul;
use XDG::BaseDirectory;

class Igo {
    has IO::Path $.directory is required where *.d;
    has IO::Path $.layout-path;

    has Str $.username;
    has Str $.password;

    method layout-path(--> IO::Path ) {
        $!layout-path //= do {
            $!directory.add: '.layout';
        }
    }

    has IO::Path $.meta-path;

    method meta-path(--> IO::Path ) {
        $!meta-path //= do {
            $!directory.add: 'META6.json';
        }
    }

    has Oyatul::Layout $.layout;

    method layout( --> Oyatul::Layout ) {
        $!layout //= do {
            if $.layout-path.f {
                Oyatul::Layout.from-json(path => $.layout-path);
            }
            else {
                self.create-layout;
            }
        }
    }

    method create-layout(--> Oyatul::Layout ) {
        my $layout = Oyatul::Layout.generate(root => $!directory);
        $.layout-path.spurt: $layout.to-json;
        $layout;
    }

    has META6 $.meta;

    method meta(--> META6) {
        $!meta //= do  {
            META6.new(file => $.meta-path);
        }
    }

    has Str $!distribution-name;

    method distribution-name(--> Str) {
        $!distribution-name //= do {
            $.meta.name.subst('::', '-', :g);
        }
    }

    has Str $!archive-directory;

    method archive-directory(--> Str) {
        $!archive-directory = do {
            "{ $.distribution-name }-{ $.meta.version }";
        }
    }

    has Str $!archive-name;

    method archive-name(--> Str) {
        $!archive-name //= do {
            "{ $.archive-directory }.tar.gz";
        }
    }

    has IO::Path $!archive-path;

    method archive-path(--> IO::Path) {
        $!archive-path //= do {
            $!directory.add: $.archive-name;
        }
    }

    method cleanup(Bool :$keep = False --> Bool) {
        if !$keep {
            self.archive-path.unlink;
        }
        True;
    }

    method distribution-files() {
        $.layout.all-children.map(*.IO).grep(*.f);
    }

    has Archive::Libarchive $!archive;

    method archive(--> Archive::Libarchive) handles <write-header write-data close> {
        $!archive //= do {
            Archive::Libarchive.new(operation => LibarchiveOverwrite, file => $.archive-path.path, format => 'v7tar', filters => [<gzip>]);
        }
    }

    method create-archive() {
        for $.distribution-files.list -> $file {
            $.write-header($.archive-directory ~ '/' ~ $file.path, size => $file.s, atime => $file.accessed.Int, ctime => $file.changed.Int, mtime => $file.modified.Int, perm => $file.mode);
            $.write-data($file.path);
        }
        $.close;
    }

    has XDG::BaseDirectory $!xdg-basedirectory;

    method xdg-basedirectory( --> XDG::BaseDirectory ) handles <load-config-paths> {
        $!xdg-basedirectory //= XDG::BaseDirectory.new;
    }

    method config-file(--> IO::Path ) {
        my IO::Path $f;

        if self.load-config-paths('igo').head -> $p {
            $f = $p.add: "pause.ini";
        }
        $f;
    }

    has CPAN::Uploader::Tiny $!uploader;

    class X::NoPauseCredentials is Exception {
        has Str $.message;
        method message( --> Str ) {
            $!message //= q:to/EOEO/;
            No PAUSE credentials found either supply 'username' and 'password'
            or create the file '~/.config/igo/pause.ini' containing:

                user <username>
                password <password>

           EOEO
        }
    }

    method uploader( --> CPAN::Uploader::Tiny ) {
        $!uploader //= do {
            if ( $!username && $!password ) {
                CPAN::Uploader::Tiny.new(user => $!username, :$!password);

            }
            elsif self.config-file.defined && self.config-file.f {
                CPAN::Uploader::Tiny.new-from-config(self.config-file.Str)
            }
            else {
                X::NoPauseCredentials.new.throw;
            }
        }
    }

    method upload( Bool :$keep = False --> Bool ) {
        if !$.archive-path.e {
            self.create-archive;
        }
        my $rc = $.uploader.upload($.archive-path.path);
        self.cleanup(:$keep);
        $rc;
    }
}

# vim: ft=perl6 sw=4 ts=4 ai
