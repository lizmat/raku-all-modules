use Test;
use XDG::BaseDirectory :terms;

plan 6;

is data-home,   XDG::BaseDirectory.new.data-home,   'data-home is correct';
is data-dirs,   XDG::BaseDirectory.new.data-dirs,   'data-dirs is correct';
is config-home, XDG::BaseDirectory.new.config-home, 'config-home is correct';
is config-dirs, XDG::BaseDirectory.new.config-dirs, 'config-dirs is correct';
is cache-home,  XDG::BaseDirectory.new.cache-home,  'cache-home is correct';
is runtime-dir, XDG::BaseDirectory.new.runtime-dir, 'runtime-dir is correct';
