use v6;

=begin pod

=head1 NAME

Audio::Hydrogen - work with Hydrogen songs and drumkits

=head1 SYNOPSIS

=begin code

=end code

=head1 DESCRIPTION

This provides the facilities for creating and manipulating drumkit and
song data of the L<Hydrogen|http://www.hydrogen-music.org/> drum software.

I originally wrote this with no other purpose than as a test for
L<XML::Class|https://github.com/jonathanstowe/XML-Class> so it may well
be missing some features that you would like to see, but please see the
examples for things that you can do with it.

This top level class doesn't provide much on its own as most of the
detail is in the other classes.

=head1 METHODS

=head2 method drumkits

This returns a list of all the drumkits found in the places that
Hydrogen would store them, it is a list of C<DrumkitInfo> classes
which simply have two attributes, C<name> (which is the name of
the Drumkit,) and C<path> which is an L<IO::Path> for tne full
path of the drumkit directory, these is a single method C<drumkit>
which returns the L<Audio::Hydrogen::Drumkit> object.

If you have drumkits in a non-standard location you can add that
path to the C<data-paths> attribute before search for the drumkits.

=end pod

use Audio::Hydrogen::Drumkit;
use Audio::Hydrogen::Song;

class Audio::Hydrogen:ver<0.0.1>:auth<github:jonathanstowe> {

    class DrumkitInfo {
        has Str $.name;
        has IO::Path $.path;

        method drumkit() returns Audio::Hydrogen::Drumkit {
            my $xml = $!path.child('drumkit.xml').slurp;
            my $dk = Audio::Hydrogen::Drumkit.from-xml($xml);
            $dk.make-absolute($!path);
            $dk;
        }
    }

    has @.data-paths = $*HOME.child('.hydrogen/data').Str, '/usr/share/hydrogen/data';

    has DrumkitInfo @.drumkits;

    method drumkits() {
        if @!drumkits.elems == 0 {
            my %seen;
            for @!data-paths.map({ $_.IO }) -> $data-path {
                if $data-path.d && $data-path.child('drumkits').d {
                    for $data-path.child('drumkits').dir -> $d-path {
                        if $d-path.d && $d-path.child('drumkit.xml').f {
                            my $base-name = $d-path.basename;
                            if not %seen{$base-name}:exists {
                                my $drumkit = DrumkitInfo.new(path => $d-path, name => $base-name);
                                @!drumkits.append: $drumkit;
                                %seen{$base-name} = True;
                            }
                        }
                    }
                }
            }
        }
        @!drumkits;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
