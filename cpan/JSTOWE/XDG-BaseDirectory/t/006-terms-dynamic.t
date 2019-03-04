use Test;
use XDG::BaseDirectory :terms;

plan 6;

my $*XDG = XDG::BaseDirectory.new(
    data-home => 'data-home'.IO,
    data-dirs   => [ 'data-dirs'.IO ],
    config-home => 'cofig-home'.IO,
    config-dirs => [ 'config-dirs'.IO ],
    cache-home => 'cache-home'.IO,
    runtime-dir => 'runtime-dir'.IO
);

is data-home,   $*XDG.data-home,   'data-home is correct';
is data-dirs,   $*XDG.data-dirs,   'data-dirs is correct';
is config-home, $*XDG.config-home, 'config-home is correct';
is config-dirs, $*XDG.config-dirs, 'config-dirs is correct';
is cache-home,  $*XDG.cache-home,  'cache-home is correct';
is runtime-dir, $*XDG.runtime-dir, 'runtime-dir is correct';

# vim: ft=perl6
