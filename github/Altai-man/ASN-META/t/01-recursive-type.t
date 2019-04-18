use ASN::META <file t/test2.asn>;
use Test;

ok Filter.new((not => Filter.new((number => 15)))).defined, "Recursive type is defined";

ok A.new(b => Filter.new((number => 15))), "Parent reference is updated";

ok Top.new(a => A.new(b => Filter.new((number => 15)))), "Grand parent reference is updated";

done-testing;
