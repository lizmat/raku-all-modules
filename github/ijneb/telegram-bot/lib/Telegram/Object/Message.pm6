unit class Telegram::Object::Message;

use Telegram::Object::Chat;
use Telegram::Object::User;
use Telegram::Object::Image;

has $.id;
has $.date;
has $.chat;
has $.text;
has $.sender;
has $.image;

method new($json) {
  my $image = Telegram::Object::Image.new($json<photo>[$json<photo>.elems - 1]) if ?$json<photo>;
  return self.bless(
    chat => Telegram::Object::Chat.new($json<chat>),
    sender => Telegram::Object::User.new($json<from>),
    image => $image,
    text => ?$json<text> ?? $json<text> !! '',
    id => $json<message_id>,
    date => Date.new(Instant.from-posix: $json<date>)
  );
}
