unit module Method::Modifiers;

sub around ($class, $method-name, &closure) is export
{
  $class.^find_method($method-name).wrap(method { closure(); });
}

sub before ($class, $method-name, &closure) is export
{
  $class.^find_method($method-name).wrap(method { closure(); nextsame; });
}

sub after ($class, $method-name, &closure) is export
{
  $class.^find_method($method-name).wrap(method { my \result = callsame; closure(); result; });
}

