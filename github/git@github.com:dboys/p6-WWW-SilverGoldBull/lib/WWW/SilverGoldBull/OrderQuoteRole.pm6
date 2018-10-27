use v6;
use WWW::SilverGoldBull::Address;
use WWW::SilverGoldBull::Types;

unit role WWW::SilverGoldBull::OrderQuoteRole;

has Str $!currency;
has $!payment-method;
has $!shipping-method;
has @!items;
has Declaration $!declaration;
has WWW::SilverGoldBull::Address $!shipping;
has WWW::SilverGoldBull::Address $!billing;

submethod BUILD(Str:D :$currency, :$payment-method, :$shipping-method, Declaration:D :$declaration, WWW::SilverGoldBull::Address:D :$shipping, WWW::SilverGoldBull::Address:D :$billing, :@items) {
  $!currency = $currency;
  $!payment-method = $payment-method;
  $!shipping-method = $shipping-method;
  $!declaration = $declaration;
  $!shipping = $shipping;
  $!billing = $billing;
  @!items = @items;
}

method to-hash() returns Hash {
  my @items;
  for @!items -> $item {
    @items.push($item.to-hash());
  }

  return %(
    'currency' => $!currency,
    'payment_method' => $!payment-method,
    'shipping_method' => $!shipping-method,
    'declaration' => $!declaration,
    'shipping' => $!shipping.to-hash(),
    'billing' => $!billing.to-hash(),
    'items' => @items
  );
}
