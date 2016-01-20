use v6.c;
use NativeCall::Errno;
use Test;

die 'expected error' if open("non-existing-file", :r);
ok(errno.code == 2);
ok(errno.message eq 'No such file or directory');
ok(errno() eqv NativeCall::Errno::ENOENT);
ok(errno() !eqv NativeCall::Errno::ENOMEM);

done-testing;
