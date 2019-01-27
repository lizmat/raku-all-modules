use Test;

use Native::Exec;

plan 15;

my $exec = $*PROGRAM.sibling('exec.p6').absolute;

ok my $proc = run($exec, 'echo', 'hello', 'world', :out), 'Run echo';
is $proc.out.slurp(:close), "hello world\n", 'output';

nok $proc = run($exec, '--nopath', 'echo', 'hello', 'world', :out, :err),
    'Run echo without searching path';
is $proc.out.slurp(:close), '', 'no output';
ok $proc.err.slurp(:close).contains('No such file or directory'),
    'no path fail';

ok $proc = run($exec, '--nopath', '/bin/echo', 'hello', 'world', :out),
    'Run /bin/echo';
is $proc.out.slurp(:close), "hello world\n", 'output';


ok $proc = run($exec, '--foo=bar', '--this=that', 'env', :out),
    'Set ENV';
ok my $out = $proc.out.slurp(:close), 'env output';
ok $out.contains('foo=bar'), 'has foo';
ok $out.contains('this=that'), 'has this';

ok $proc = run($exec, '--nopath', '--foo=bar', '--this=that',
               '/usr/bin/env', :out), 'env with nopath Set ENV';
ok $out = $proc.out.slurp(:close), 'env output';
ok $out.contains('foo=bar'), 'has foo';
ok $out.contains('this=that'), 'has this';

done-testing;
