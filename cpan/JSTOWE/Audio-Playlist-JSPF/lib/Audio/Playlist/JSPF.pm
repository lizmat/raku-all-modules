use v6;

use JSON::Name;
use JSON::Class;

=begin pod

=head1 NAME

Audio::Playlist::JSPF - JSON playlist description

=head1 SYNOPSIS

=begin code

    use Audio::Playlist::JSPF;

    my $playlist = Audio::Playlist::JSPF.new(title => "My New Playlist");
    $playlist.track.append: Audio::Playlist::JSPF::Track.new(title => "some track", location => ["http://example.com/mp3"]);

    # etc

    my $json = $playlist.to-json;

    # do something with the JSON

=end code

=head1 DESCRIPTION

This is a JSON representation of L<XSPF|http://xspf.org/> which is
a format for sharing media playlists.

Because this does the role L<JSON::Class> the objects can be created
directly from and serialised to JSON via the C<from-json> and C<to-json>
methods that role provides.

=head2 method add-track

    method add-track(*%track-data) returns Track

This is a convenience for adding a new track to the playlist, the named arguments
should be the names of the attributes of L<Track> described below, it returns the
newly created track object.

=head2 attribute title

A human readable title for the playlist.

=head2 attribute creator

A human readable name of creator of the playlist.

=head2 attribute annotation

Free text annotation or description of the playlist.
This should only contain plain text, not markup.

=head2 attribute info

The URI of a web page with further information about the playlist.

=head2 attribute location

The source URI of the playlist. (i.e. where it can be downloaded)

=head2 attribute identifier

The canonical identifier for the playlist, it should be formed as
a valid URI but would typically be location independent.

=head2 attribute image

The URI of an image that may be displayed in place of a missing
image attribute on a track.

=head2 attribute date

Creation date of the playlist as a DateTime (this will be parsed
from and marshalled as IS08601 from/to JSON)

=head2 attribute license

The URI of a license under which the playlist was release.,

=head2 attribute attribution

This is a list of L<Attribution> objects, indication the original
C<location> and C<identifier> of a Playlist that this playlist may be
based on, with the most recent antecedent first.  Typically will be a
maximum of ten items.

=head2 attribute track

This an Array of L<Track> objects in the suggested order that they should
be played.  The C<Track> object has the following attributes that describe
the track:

=head3 attribute location

An Array of URIs for the resource (typically an audio file or stream,) each
URI should refer to a different format or representation of the same source
and a client should only use exactly one when playing the playlist.

=head3 attribute identifier

A unique and canonical identifier for the track in URI format.

=head3 attribute title

The human readable title (or track name.)

=head3 attribute creator

The human readable name of the creator of the resource.

=head3 attribute annotation

A human readable annotation or description of the resource.

=head3 attribute info

A URI of a location where more information about the track can be
found.

=head3 attribute image

The URI of an image that may be displayed to represent this track.
If it is not present the playlist image may be used instead.

=head3 attribute album

The human readable name of the "album" or collection from which the
track comes from.

=head3 attribute track-number

This is the track number from an album or other collection that this
track represents.


=head3 attribute duration

A L<Duration> object, representing the length of the track, it is
converted to/from milliseconds on conversion to/from JSON.

=end pod

class Audio::Playlist::JSPF:ver<0.0.3>:auth<github:jonathanstowe>:api<1.0> does JSON::Class {

    class Attribution does JSON::Class {
        has Str $.identifier    is rw;
        has Str $.location      is rw;
    }

    class Track does JSON::Class {
        has Str         @.identifier;
        has Str         $.album         is rw;
        has Int         $.track-number  is rw is json-name('trackNum') = 0;
        has Str         $.title         is rw is required;
        has Str         $.info          is rw is json-skip-null;
        has Str         $.annotation    is rw is json-skip-null;
        has Str         $.image         is rw is json-skip-null;
        has Str         @.location;
        has Str         $.creator       is rw is json-skip-null;
        sub duration-from-millis($m --> Duration ) { Duration.new($m/1000) }
        sub millis-from-duration($d --> Int ) { ($d.Rat * 1000).Int }
        has Duration    $.duration      is unmarshalled-by(&duration-from-millis) is marshalled-by(&millis-from-duration) is json-skip-null;
    }

    class Playlist does JSON::Class {
        has Str         $.identifier    is rw is json-skip-null;
        has Str         $.title         is rw is required;
        has Attribution @.attribution;
        has Str         $.info          is rw is json-skip-null;
        has Str         $.annotation    is rw is json-skip-null;
        has Str         $.image         is rw is json-skip-null;
        has Str         $.license       is rw is json-skip-null;
        has Str         $.creator       is rw is json-skip-null;
        has Str         $.location      is rw is json-skip-null;
        has Track       @.track;
        has DateTime    $.date          is unmarshalled-by('new') is marshalled-by('Str') = DateTime.now;

        method add-track(*%track-data --> Track) {
            my $track = Track.new(|%track-data);
            @!track.append: $track;
            $track;
        }
    }

    has Playlist $.playlist  handles <identifier title attribution info annotation image license create location track date add-track>;

    multi submethod BUILD(*%args) {
        if %args<playlist>:exists {
            if %args<playlist> ~~ Playlist {
                $!playlist = %args<playlist>;
            }
            else {
                $!playlist = Playlist.new(|%args<playlist>);
            }
        }
        else {
            $!playlist = Playlist.new(|%args);
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
