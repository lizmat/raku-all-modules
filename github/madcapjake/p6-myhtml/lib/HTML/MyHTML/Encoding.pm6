unit module HTML::MyHTML::Encoding;

my %encodings =
  default          => 0x00,
  auto             => 0x01, # future
  custom           => 0x02, # future
  utf_8            => 0x00, # default encoding
  utf_16le         => 0x04,
  utf_16be         => 0x05,
  x_user_defined   => 0x06,
  big5             => 0x07,
  euc_kr           => 0x08,
  gb18030          => 0x09,
  ibm866           => 0x0a,
  iso_8859_10      => 0x0b,
  iso_8859_13      => 0x0c,
  iso_8859_14      => 0x0d,
  iso_8859_15      => 0x0e,
  iso_8859_16      => 0x0f,
  iso_8859_2       => 0x10,
  iso_8859_3       => 0x11,
  iso_8859_4       => 0x12,
  iso_8859_5       => 0x13,
  iso_8859_6       => 0x14,
  iso_8859_7       => 0x15,
  iso_8859_8       => 0x16,
  koi8_r           => 0x17,
  koi8_u           => 0x18,
  macintosh        => 0x19,
  windows_1250     => 0x1a,
  windows_1251     => 0x1b,
  windows_1252     => 0x1c,
  windows_1253     => 0x1d,
  windows_1254     => 0x1e,
  windows_1255     => 0x1f,
  windows_1256     => 0x20,
  windows_1257     => 0x21,
  windows_1258     => 0x22,
  windows_874      => 0x23,
  x_mac_cyrillic   => 0x24;

class Enc is export {
  my $.default = %encodings<default>;
  method AT-KEY(Str $enc --> int) {
    %encodings{$enc.lc.trans(['-'] => ['_'])}
  }
}
