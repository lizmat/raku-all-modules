use v6;
use lib 'lib';
use Test;
use Platform::Util::OS;

plan 8;

use-ok 'Platform::Util::OS', 'load Platform::Util::OS';

ok Platform::Util::OS.detect(),'Platform::Util::OS.detect call.1';
Platform::Util::OS.clear();
is Platform::Util::OS.new(:kernel('darwin')).detect(), 'macos', 'macos variant';
is Platform::Util::OS.detect(), 'macos', 'macos variant subsequent call';

Platform::Util::OS.clear();
is Platform::Util::OS.new(:kernel('linux')).detect(), 'linux', 'linux variant';
is Platform::Util::OS.detect(), 'linux', 'linux variant subsequent call';

Platform::Util::OS.clear();
is Platform::Util::OS.new(:kernel('win32')).detect(), 'windows', 'windows variant';
is Platform::Util::OS.detect(), 'windows', 'windows variant subsequent call';
