unit package JSON::WebToken::Exception;


sub throw-error is export {
  my (%err) = @_;
  die %err;
}

sub code is export { $_[0]{code}; }

sub message { $_[0]{message}; }

sub to_string { $_[0].message; }

=finish
