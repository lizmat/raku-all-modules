use v6;
use TagLibC;

=begin pod
=TITLE TagLibC
=SUBTITLE TagLib C bindings in Perl6

=begin SYNOPSIS
provides bindings to C<libtag_c.so> or C<libtag_c.dynlib> or your systems equivalent, you're able to change and read title, track, album, artist, year and genre.

you're also able to read (but not change) samplerate, length, channels and bitrate

=end SYNOPSIS
=end pod

#| An easy wrapper object for taglib_c
class TagLibC::Wrapper {
  # Pointers
  has $.file-pointer is rw;
  has $.tag-pointer is rw;
  has $.audio-properties-pointer is rw;

  has $.is-destroyed is rw = False;

  #| Creates a new TagLibC::Wrapper object from file given.
  #|
  #| Throws when file doesn't exist
  method new(Str $path --> TagLibC::Wrapper) {
    my $obj = self.bless;

    if ! IO::Path.new($path).f {
      X::AdHoc.new(payload => "File doesn't exist: $path").throw;
    }

    $obj.file-pointer = taglib_file_new($path);
    $obj.tag-pointer = taglib_file_tag($obj.file-pointer);
    $obj.audio-properties-pointer = taglib_file_audioproperties($obj.file-pointer);
    return $obj;
  }

  #| Gets a hash with all available info e.g.
  #|
  #|     {
  #|        album => "Edited & Forgotten",
  #|        artist => "Sinister Souls",
  #|        genre => "",
  #|        info => {
  #|            bitrate => 270,
  #|            channels => 2,
  #|            length => 311,
  #|            samplerate => 44100
  #|        },
  #|        title => "3D",
  #|        track => 3,
  #|        year => 2014
  #|     }
  #|
  method get-hash (--> Hash)
  {
    return {
      artist => self.artist,
      genre  => self.genre,
      title  => self.title,
      year   => self.year,
      album  => self.album,
      track  => self.track,
      info => {
        length => self.length,
        bitrate => self.bitrate,
        channels => self.channels,
        samplerate => self.samplerate
      }
    };
  }

  #| Get length from this file in seconds
  method length (--> Int) {
    taglib_audioproperties_length(self.audio-properties-pointer);
  }

  #| Get bitrate from this file
  method bitrate (--> Int) {
    taglib_audioproperties_bitrate(self.audio-properties-pointer);
  }

  #| Get amount of channels from this file
  method channels (--> Int) {
    taglib_audioproperties_channels(self.audio-properties-pointer);
  }

  #| Get the samplerate from this file
  method samplerate (--> Int) {
    taglib_audioproperties_samplerate(self.audio-properties-pointer);
  }

  #| Validate the current file, throws if it's destroyed or not valid
  method validate () {
    if $.is-destroyed {
      X::AdHoc.new(payload => "Wrapper is destroyed and can't be used anymore").throw;
    }

    if ! taglib_file_is_valid $.file-pointer {
      X::AdHoc.new(payload => "File pointer isn't vaild").throw;
    }
  }

  #| Get the artist
  multi method artist (--> Str) {
    self.validate;
    taglib_tag_artist($.tag-pointer);
  }

  #| Set the artist
  multi method artist(Str $artist) {
    self.validate;
    taglib_tag_set_artist($.tag-pointer, $artist);
  }

  #| Get the title
  multi method title (--> Str) {
    self.validate;
    taglib_tag_title($.tag-pointer);
  }

  #| Set the title
  multi method title(Str $title) {
    self.validate;
    taglib_tag_set_title($.tag-pointer, $title);
  }

  #| Get the album
  multi method album (--> Str) {
    self.validate;
    taglib_tag_album($.tag-pointer);
  }

  #| Set the album
  multi method album(Str $album) {
    self.validate;
    taglib_tag_set_album($.tag-pointer, $album);
  }

  #| Get the comment
  multi method comment (--> Str) {
    self.validate;
    taglib_tag_comment($.tag-pointer);
  }

  #| Set the comment
  multi method comment(Str $comment) {
    self.validate;
    taglib_tag_set_comment($.tag-pointer, $comment);
  }

  #| Get the genre
  multi method genre (--> Str) {
    self.validate;
    taglib_tag_genre($.tag-pointer);
  }

  #| Set the genre
  multi method genre(Str $genre) {
    self.validate;
    taglib_tag_set_genre($.tag-pointer, $genre);
  }

  #| Get the year
  multi method year (--> Int) {
    self.validate;
    taglib_tag_year($.tag-pointer);
  }

  #| Set the year
  multi method year($year) {
    self.year($year.Int);
  }

  #| Set the year
  multi method year(Int $year) {
    self.validate;
    taglib_tag_set_year($.tag-pointer, $year);
  }

  #| Get the track
  multi method track(--> Int) {
    self.validate;
    taglib_tag_track($.tag-pointer);
  }

  #| Set the track
  multi method track($track) {
    self.track($track.Int);
  }

  #| Set the track
  multi method track(Int $track) {
    self.validate;
    taglib_tag_set_track($.tag-pointer, $track);
  }

  #| Free all memory and destroy this object
  method destroy () {
    $.is-destroyed = True;
    taglib_file_free($.file-pointer);
  }

  #| Write all changes to the filesystem
  method save () {
    taglib_file_save($.file-pointer);
  }
}
