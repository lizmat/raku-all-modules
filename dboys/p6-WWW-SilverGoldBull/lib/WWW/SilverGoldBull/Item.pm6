use v6;

use WWW::SilverGoldBull::CommonMethodsRole;

unit class WWW::SilverGoldBull::Item does WWW::SilverGoldBull::CommonMethodsRole;

has Str $!id;
has Rat $!bid-price;
has Int $!qty;

submethod BUILD(Str:D :$id, Int:D :$qty, Rat :$bid-price = 0.0) {
  $!id = $id;
  $!qty = $qty;
  $!bid-price = $bid-price;
}

method to-hash() returns Hash {
  my %hash;

  for %(id => $!id, qty => $!qty, bid_price => $!bid-price).kv -> $key, $val {
    if ?$val {
      %hash{$key} = $val;
    }
  }

  return %hash;
}
