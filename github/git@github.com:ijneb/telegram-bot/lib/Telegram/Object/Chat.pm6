unit class Telegram::Object::Chat;

enum Type <private group supergroup channel>;

has $.id;
has $.type;
has $.title;

method new($json) {
  return self.bless(
    id => $json<id>,
    type => $json<type>,
    title => ?$json<title> ?? $json<title> !! Nil
  );
}
