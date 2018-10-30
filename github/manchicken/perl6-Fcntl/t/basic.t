use v6.c;
use Test;
plan 3;

use lib 'lib';
use NativeCall;

use-ok 'Fcntl', 'Verify that we can use the module.';
use Fcntl :SEEK_SET, :SEEK_CUR, :SEEK_END, :O_DIRECTORY;

subtest {
  plan 3;
  is SEEK_SET, 0, 'Verify SEEK_SET...';
  is SEEK_CUR, 1, 'Verify SEEK_CUR...';
  is SEEK_END, 2, 'Verify SEEK_END...';
}

subtest {
  plan 143;
  my sub verify_one_named_value(Str, longlong --> Str) is native('resources/lib/just-for-tests') { * }

  for Fcntl::.kv -> $name, $value {
    next if $name eq 'EXPORT';
    is verify_one_named_value($name, $value), 'OK', "Verify «$name» is what C thinks...";
  }
}

done-testing;
