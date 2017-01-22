use v6;
use Test;
use lib 'lib';

use Concurrent::File::Find;

plan 10;

is find('t/root/').elems, 3, 'can find files';
is find('t/root/', :directory).elems, 4, 'can find files and directories';
is find('t/root/', :!file, :directory).elems, 1, 'can only and directories';
is find('t/root/', :!recursive).elems, 0, 'may not recurse';
is find('t/root/', :max-depth(2)).elems, 0, 'don`t go too deep';
is find('t/root/', :name('file.bin')).elems, 1, 'find exact filename';
is find('t/root/', :extension('bin')).elems, 1, 'find by exact extension';
is find('t/root/', :extension(/a/)).elems, 2, 'find by partial extension';
is find('t/root/', :exclude-dir('directory')).elems, 0, 'exclude a directory';
is find('t/root/', :no-thread).elems, 3, 'single thread';
