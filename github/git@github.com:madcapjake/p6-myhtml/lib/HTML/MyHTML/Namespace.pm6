unit module HTML::MyHTML::Namespace;

my %namespaces =
  UNDEF      => 0x00,
  HTML       => 0x01,
  MATHML     => 0x02,
  SVG        => 0x03,
  XLINK      => 0x04,
  XML        => 0x05,
  XMLNS      => 0x06;

class Namespace is export {
  has $.default = %namespaces<HTML>;
  method AT-KEY(Str $ns --> int) { %namespaces{$ns.UC} }
}
