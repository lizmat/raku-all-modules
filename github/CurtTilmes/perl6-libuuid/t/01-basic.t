use v6;

use Test;
use LibUUID;

plan 9;

ok my $uuid = UUID.new, 'Generate UUID';

is $uuid.Blob.bytes, 16, 'Blob has 16 bytes';

like ~$uuid, /<:hexdigit> ** 8 '-'
              <:hexdigit> ** 4 '-'
              <:hexdigit> ** 4 '-'
              <:hexdigit> ** 4 '-'
              <:hexdigit> ** 12/, 'String has right format';

ok $uuid = UUID.new(buf8.new(57,237,117,14,161,191,71,146,129,214,224,152,240,17,82,211)), "Make UUID from Blob";

is $uuid.Blob, buf8.new(57,237,117,14,161,191,71,146,129,214,224,152,240,17,82,211), 'Blobify';

is ~$uuid, '39ed750e-a1bf-4792-81d6-e098f01152d3', 'Stringify';

ok $uuid = UUID.new('39ed750e-a1bf-4792-81d6-e098f01152d3'), 'New from Str';

is $uuid.Blob, buf8.new(57,237,117,14,161,191,71,146,129,214,224,152,240,17,82,211), 'Blobify';

is ~$uuid, '39ed750e-a1bf-4792-81d6-e098f01152d3', 'Stringify';

done-testing;
