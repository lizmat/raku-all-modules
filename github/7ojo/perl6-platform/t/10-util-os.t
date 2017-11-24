use v6;
use lib 'lib';
use Test;
use App::Platform::Util::OS;

plan 8;

use-ok 'App::Platform::Util::OS', 'load App::Platform::Util::OS';

ok App::Platform::Util::OS.detect(),'App::Platform::Util::OS.detect call.1';
App::Platform::Util::OS.clear();
is App::Platform::Util::OS.new(:kernel('darwin')).detect(), 'macos', 'macos variant';
is App::Platform::Util::OS.detect(), 'macos', 'macos variant subsequent call';

App::Platform::Util::OS.clear();
is App::Platform::Util::OS.new(:kernel('linux')).detect(), 'linux', 'linux variant';
is App::Platform::Util::OS.detect(), 'linux', 'linux variant subsequent call';

App::Platform::Util::OS.clear();
is App::Platform::Util::OS.new(:kernel('win32')).detect(), 'windows', 'windows variant';
is App::Platform::Util::OS.detect(), 'windows', 'windows variant subsequent call';
