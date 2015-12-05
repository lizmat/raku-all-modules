use v6;
use Test;
plan 1;
use lib <lib blib>;


skip-rest('Do not have Test::Pod::Coverage module');


#todo do not have this testing module to check for documentation coverage
# Eval "use Test::Pod::Coverage 1.04";
# plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

# all_pod_coverage_ok({ also_private => [ qr/removeChildAt/ ] });
