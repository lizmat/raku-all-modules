use v6.c;

=begin pod

=head1 NAME

XDG::BaseDirectory - locate shared data and configuration

=head1 SYNOPSIS

=begin code

    my $bd = XDG::BaseDirectory.new

    for $bd.load-config-paths('mydomain.org', 'MyProg', 'Options') -> $d {
        say $d;
    }

=end code

=head1 DESCRIPTION

The freedesktop.org Base Directory specification provides a way for
applications to locate shared data and configuration:

    http://standards.freedesktop.org/basedir-spec/

This module can be used to load and save from and to these directories.

The interface is loosely based on that of the C<pyxdg> module, however all
methods that return a string path in that module return an L<IO::Path> here.

=head2 METHODS

=end pod

class XDG::BaseDirectory:ver<0.0.3>:auth<github:jonathanstowe> {

=begin pod

=head2 data-home

This reflects the base path where local data should be stored.  Can be
over-ridden by the environment variable C<XDG_DATA_HOME>.

=end pod

    has IO::Path $.data-home; 
    
    method data-home() returns IO::Path {
        $!data-home //= %*ENV<XDG_DATA_HOME>.defined ?? %*ENV<XDG_DATA_HOME>.IO !! $*HOME.child($*SPEC.catfile('.local', 'share'));

    }

=begin pod 

=head2 data-dirs

This returns a list of the locations where data can be read from, it can
be over-ridden by the colon separated environment variable C<XDG_DATA_DIRS>
but will always prefer C<data-home>.

=end pod

    has IO::Path @.data-dirs;

    method data-dirs() {
        if ! @!data-dirs.elems {
            @!data-dirs = ($.data-home, (%*ENV<XDG_DATA_DIRS> || '/usr/local/share:/usr/share').split(':').map({ $_.IO })).flat;
        }
        @!data-dirs;
    }

=begin pod

=head2 config-home

Reflects the location where application should be saved to to.  Can
be over-ridden by the enviroment variable C<XDG_CONFIG_HOME>.


=end pod

    has IO::Path $.config-home;

    method config-home() returns IO::Path {
        $!config-home //= %*ENV<XDG_CONFIG_HOME>.defined ?? %*ENV<XDG_CONFIG_HOME>.IO !! $*HOME.child('.config');
    }

=begin pod

=head2 config-dirs

returns a list of directorys from which configuration can be read, it will
always prefer C<config-home> but the defaults can be over-ridden by the
environment variable C<XDG_CONFIG_DIRS> which can be a list separated by
colons.

=end pod

    has IO::Path @.config-dirs;

    method config-dirs() {
        if ! @!config-dirs.elems {
            @!config-dirs = ($.config-home, (%*ENV<XDG_CONFIG_DIRS> || '/etc/xdg' ).split(':').map({ $_.IO })).flat;
        }
        @!config-dirs;
    }

=begin pod

=head2 cache-home

Returns the path where application cache data should be saved. This can be
over-ridden by the environment variable C<XDG_CACHE_HOME>.

=end pod

    has IO::Path $.cache-home;

    method cache-home() returns IO::Path {
        $!cache-home //= %*ENV<XDG_CACHE_HOME> || $*HOME.child('.cache');
    }

=begin pod

=head2 save-config-path(Str *@resource)

Ensure C< <config-home>/<resource>/> exists, and return its path.
'resource' should normally be the name of your application. Use this
when SAVING configuration settings. Use the C<config-dirs> variable
for loading.

=end pod

    method save-config-path(*@resource where @resource.elems > 0 ) returns IO::Path {
        self!home-path($.config-home, @resource);
    }

=begin pod

=head3 save-data-path(Str *@resource)

Ensure C< <data-home>/<resource>/> exists, and return its path.
'resource' is the name of some shared resource. Use this when updating
a shared (between programs) database. Use the C<data-dirs> variable
for loading.


=end pod

    method save-data-path(*@resource where @resource.elems > 0) {
        self!home-path($.data-home, @resource);
    }

    # given an IO::Path and a resource description, will return an IO::Path of the
    # appropriate sub-directory which will be created if necessary
    method !home-path(IO::Path $home-path, *@resource where @resource.elems > 0 ) {
        my Str $resource = self!resource-path(@resource);

        my IO::Path $path = $home-path.child($resource);

        if ! $path.d {
            $path.mkdir(mode => 0o700);
        }
        $path.cleanup;
    }

=begin pod

=head3 load-config-paths

Returns an iterator which gives each directory named 'resource' in the
configuration search path. Information provided by earlier directories should
take precedence over later ones (ie, the user's config dir comes first).

=end pod

    method load-config-paths(*@resource ) {
        self!load-resource-paths(@.config-dirs, @resource);
    }

=begin pod

=head3 load-first-config(Str *@resource) returns L<IO::Path>

Returns the first result from load-config-paths, or None if there is nothing to load.

=end pod

    method load-first-config(*@resource) {
        self.load-config-paths(@resource)[0];
    }

=begin pod

=head3 load-data-paths(Str *@resource) 

Returns an iterator which gives each directory named 'resource' in the
shared data search path. Information provided by earlier directories should
take precedence over later ones.


=end pod 

    method load-data-paths(*@resource where @resource.elems > 0 ) {
        self!load-resource-paths(@.data-dirs, @resource);
    }

    # given an array of IO::Path objects and a resource description
    # return those resulting resource paths that actually exist
    method !load-resource-paths(@dirs, *@resource where @resource.elems > 0 ) {
        my Str $resource = self!resource-path(@resource);
        gather {
            for @dirs -> $config-dir {
                my $path = $config-dir.child($resource);

                if $path.d {
                    take $path;
                }
            }
        }
    }

    # return a somewhat sanitized path part that can be appended to
    # some config path based on the supplied resource description parts
    method !resource-path(*@resource where @resource.elems > 0) {

        if @resource ~~ $*SPEC.updir {
            die "invalid resource description";
        }
        my Str $resource = $*SPEC.catfile(@resource);

        if $resource.IO.is-absolute {
            die "absolute path $resource is not allowed";
        }

        $resource;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
