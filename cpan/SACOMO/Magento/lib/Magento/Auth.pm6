use v6;

use Magento::HTTP;
use Magento::Integration;

unit module Magento::Auth;

subset UserType of Str where 'admin'|'customer';
our sub request-access-token(
    Str      :$username,
    Str      :$password,
    UserType :$user_type = 'admin',
    Str      :$host
    --> Str
) is export {

    my %credentials = %{
        username => $username,
        password => $password
    }

    my $access_token = integration-token %( :$host ), :$user_type, data => %credentials;
    return S:g/<["]>// given $access_token;
}
