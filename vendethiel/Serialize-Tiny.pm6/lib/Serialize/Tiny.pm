module Serialize::Tiny;

sub serialize(Mu:D \obj) is export {
  my \type = obj.WHAT;
  my @attribute = type.^attributes.grep(*.has-accessor);
  @attribute.map({.name.substr(2), .get_value(obj)}).hash
}
