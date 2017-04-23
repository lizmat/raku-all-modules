use v6;
use TagLibC;

class TagLibC::Wrapper {
  # Pointers
  has $.file-pointer is rw;
  has $.tag-pointer is rw;
  has $.audio-properties-pointer is rw;

  has $.is-destroyed is rw = False;

  method new(Str $path) {
    my $obj = self.bless;

    if ! IO::Path.new($path).f {
      die "File doesn't exist: $path";
    }

    $obj.file-pointer = taglib_file_new($path);
    $obj.tag-pointer = taglib_file_tag($obj.file-pointer);
    $obj.audio-properties-pointer = taglib_file_audioproperties($obj.file-pointer);
    return $obj;
  }

  method get-hash {
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

  method length {
    taglib_audioproperties_length(self.audio-properties-pointer);
  }

  method bitrate {
    taglib_audioproperties_bitrate(self.audio-properties-pointer);
  }

  method channels {
    taglib_audioproperties_channels(self.audio-properties-pointer);
  }

  method samplerate {
    taglib_audioproperties_samplerate(self.audio-properties-pointer);
  }

  method validate {
    if $.is-destroyed {
      die "Wrapper is destroyed and can't be used anymore";
    }

    if ! taglib_file_is_valid $.file-pointer {
      die "File pointer isn't vaild";
    }
  }

  multi method artist {
    self.validate;
    taglib_tag_artist($.tag-pointer);
  }

  multi method artist(Str $artist) {
    self.validate;
    taglib_tag_set_artist($.tag-pointer, $artist);
  }

  multi method title {
    self.validate;
    taglib_tag_title($.tag-pointer);
  }

  multi method title(Str $title) {
    self.validate;
    taglib_tag_set_title($.tag-pointer, $title);
  }

  multi method album {
    self.validate;
    taglib_tag_album($.tag-pointer);
  }

  multi method album(Str $album) {
    self.validate;
    taglib_tag_set_album($.tag-pointer, $album);
  }

  multi method comment {
    self.validate;
    taglib_tag_comment($.tag-pointer);
  }

  multi method comment(Str $comment) {
    self.validate;
    taglib_tag_set_comment($.tag-pointer, $comment);
  }

  multi method genre {
    self.validate;
    taglib_tag_genre($.tag-pointer);
  }

  multi method genre(Str $genre) {
    self.validate;
    taglib_tag_set_genre($.tag-pointer, $genre);
  }

  multi method year {
    self.validate;
    taglib_tag_year($.tag-pointer);
  }

  multi method year($year) {
    self.year($year.Int);
  }

  multi method year(Int $year) {
    self.validate;
    taglib_tag_set_year($.tag-pointer, $year);
  }

  multi method track {
    self.validate;
    taglib_tag_track($.tag-pointer);
  }

  multi method track($track) {
    self.track($track.Int);
  }

  multi method track(Int $track) {
    self.validate;
    taglib_tag_set_track($.tag-pointer, $track);
  }

  method destroy {
    $.is-destroyed = True;
    taglib_file_free($.file-pointer);
  }

  method save {
    taglib_file_save($.file-pointer);
  }
}
