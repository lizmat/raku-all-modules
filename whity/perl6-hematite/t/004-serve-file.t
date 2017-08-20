use v6;

use Test;
use HTTP::Request;
use Crust::Test;
use Hematite;

sub MAIN() {
    my $app = Hematite.new;

    done-testing;
}
