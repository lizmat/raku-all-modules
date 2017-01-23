#!/usr/bin/env perl6

use v6;
use lib "lib";
use Odoo::Client;
use MIME::Base64;

# Create a new odoo JSON-RPC client
my $odoo = Odoo::Client.new(
    hostname => "localhost",
    port     => 8069
);

# Login to odoo
my $uid = $odoo.login(
    database => "sample", 
    username => 'user@example.com',
    password => "123"
);

# Print the Odoo instance version information
say "Version: " ~ $odoo.version.perl;

unless $uid.defined {
    die "Failed to login to odoo";
}

printf("Logged on with user id '%d'\n", $uid);

# User model
my $user-model = $odoo.model( 'res.users' );
say $user-model.perl;

# Get all user ids
my $user-ids   = $user-model.search( [] );
unless $user-ids.defined && $user-ids.elems > 0 {
    die "No users found!";
    return;
}
say "user-ids: " ~ $user-ids.perl;

# Print first user information
my $user-id = $user-ids[0];
my $user    = $user-model.read([$user-id]);
die "Duplicate user id" if $user.elems > 1;
die "User not found!"   if $user.elems == 0;
say "user: " ~ $user[0].perl;

# Create a product (needs the CRM and sale app to be install)
sub create-product($name, $type, $list-price, $image) {
    my $product-model = $odoo.model('product.product');
    my $base64-image  = MIME::Base64.encode($image);
    return $product-model.create({
        "name"       => $name,
        "type"       => $type,
        "list_price" => $list-price,
        "image"      => $base64-image
    });
}

# Create a product to be sold :)
my $perl6-book-image = "logotype/logo_32x32.png".IO.slurp(:bin);
my $product = create-product('Perl 6 and Odoo', 'consu', 29.99, $perl6-book-image);
say $product.perl;
