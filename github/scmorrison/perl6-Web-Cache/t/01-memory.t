use v6;
use lib 'lib';

use Test;
use Web::Cache;

plan 7;

my $key = "web-cache-test-key";
my $content = q:to/EOS/; 
  <html>
    <head>
      <title>Web::Cache Test</title>
      <body>
        This is only a test.
      </body>
  </html>
EOS


# Memory
my &memory-store = cache-create-store size    => 2048,
                                      backend => 'memory';

is &memory-store.WHAT, Block, 'memory 1/7: create memory closure';

# Memory: set
my $m1 = memory-store(key => $key, { $content });
is $m1, $content, 'memory 2/7: cache set key';

# Memory: get
my $m2 = memory-store(key => $key);
is $m2, $content, 'memory 3/7: cache get key';

# Memory: remove
my $m3 = memory-store(key => $key, :remove);
is $m3, $content, 'memory 4/7: cache remove key';

# Memory: webcache initial key insert
my $m4 = memory-store(key => $key, { $content });
is $m4, $content, 'memory 5/7: webcache initial key insert';

# Memory: webcache subsequent key insert
my $m5 = memory-store(key => $key, { $content });
is $m5, $content, 'memory 6/7: webcache subsequent key insert';

# Memory: webcache clear
my $m6 = memory-store(:clear);
is $m6, '', 'memory 7/7: cache clear';
