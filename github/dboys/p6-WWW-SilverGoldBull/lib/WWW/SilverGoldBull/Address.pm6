use v6;
use WWW::SilverGoldBull::CommonMethodsRole;

unit class WWW::SilverGoldBull::Address does WWW::SilverGoldBull::CommonMethodsRole;

has Str $!country;
has Str $!first-name;
has Str $!last-name;
has Str $!street;
has Str $!city;
has Str $!company;
has Str $!region;
has Str $!phone;
has Str $!postcode;
has Str $!email;

submethod BUILD(Str:D :$country, Str:D :$first-name, Str:D :$last-name, Str:D :$street, Str:D :$city, Str :$company = '', Str :$region = '', Str :$phone = '', Str :$postcode = '', Str :$email = '') {
  $!country = $country;
  $!first-name = $first-name;
  $!last-name = $last-name;
  $!street = $street;
  $!city = $city;
  $!company = $company;
  $!region = $region;
  $!phone = $phone;
  $!postcode = $postcode;
  $!email = $email;
}

method to-hash() {
  my %hash = (
    'country' => $!country,
    'first_name' => $!first-name,
    'last_name' => $!last-name,
    'street' => $!street,
    'city' => $!city,
  );

  for %('company' => $!company, 'region' => $!region, 'phone' => $!phone, 'postcode' => $!postcode, 'email' => $!email).kv -> $key, $val {
    if ?$val {
      %hash{$key} = $val;
    }
  }

  return %hash;
}
