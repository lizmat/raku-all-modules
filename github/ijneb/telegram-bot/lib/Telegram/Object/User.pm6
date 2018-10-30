unit class Telegram::Object::User;

has $.id;
has $.is_bot;
has $.username;
has $.firstname;
has $.lastname;

method new($json) {
  return self.bless(
    id => $json<id>,
    is_bot => $json<is_bot>,
    username => ?$json<username> ?? $json<username> !! '',
    firstname => ?$json<first_name> ?? $json<first_name> !! '',
    lastname => ?$json<last_name> ?? $json<last_name> !! ''
  );
}
