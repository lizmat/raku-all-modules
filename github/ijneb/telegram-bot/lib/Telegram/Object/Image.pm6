unit class Telegram::Object::Image;

has $!id;
has $.size;
has $.width;
has $.height;

method new($json) {
  return self.bless(
    id => $json<file_id>,
    size => $json<file_size>,
    width => $json<width>,
    height => $json<height>
  );
}
