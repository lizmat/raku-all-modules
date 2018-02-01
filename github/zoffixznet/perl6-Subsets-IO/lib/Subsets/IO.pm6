use Subset::Helper;

my subset IO::Path::e is export(:e, :DEFAULT)
  of IO::Path:D where subset-is *.e,
  'Path must exist';
my subset IO::Path::E is export(:E, :DEFAULT)
  of IO::Path:D where subset-is *.e.not,
  'Path must NOT exist';

my subset IO::Path::f is export(:f, :DEFAULT)
  of IO::Path:D where subset-is *.f,
  'Path must be an existing file';
my subset IO::Path::F is export(:F, :DEFAULT)
  of IO::Path:D where subset-is *.f.not,
  'Path must NOT be an existing file';

my subset IO::Path::d is export(:d, :DEFAULT)
  of IO::Path:D where subset-is *.d,
  'Path must be an existing directory';
my subset IO::Path::D is export(:D, :DEFAULT)
  of IO::Path:D where subset-is *.d.not,
  'Path must NOT be an existing directory';


my subset IO::Path::fr is export(:fr, :DEFAULT)
  of IO::Path:D where subset-is {.f and .r},
  'Path must be an existing, readable file';
my subset IO::Path::frw is export(:frw, :DEFAULT)
  of IO::Path:D where subset-is {.f and .rw},
  'Path must be an existing, readable and writable file';
my subset IO::Path::frx is export(:frx, :DEFAULT)
  of IO::Path:D where subset-is {.f and .r and .x},
  'Path must be an existing, readable and executable file';
my subset IO::Path::fwx is export(:fwx, :DEFAULT)
  of IO::Path:D where subset-is {.f and .w and .x},
  'Path must be an existing, writable and executable file';
my subset IO::Path::frwx is export(:frwx, :DEFAULT)
  of IO::Path:D where subset-is {.f and .rwx},
  'Path must be an existing, readable, writable, and executable file';

my subset IO::Path::dr is export(:dr, :DEFAULT)
  of IO::Path:D where subset-is {.d and .r},
  'Path must be an existing, readable directory';
my subset IO::Path::drw is export(:drw, :DEFAULT)
  of IO::Path:D where subset-is {.d and .rw},
  'Path must be an existing, readable and writable directory';
my subset IO::Path::drx is export(:drx, :DEFAULT)
  of IO::Path:D where subset-is {.d and .r and .x},
  'Path must be an existing, readable and executable directory';
my subset IO::Path::dwx is export(:dwx, :DEFAULT)
  of IO::Path:D where subset-is {.d and .w and .x},
  'Path must be an existing, writable and executable directory';
my subset IO::Path::drwx is export(:drwx, :DEFAULT)
  of IO::Path:D where subset-is {.d and .rwx},
  'Path must be an existing, readable, writable, and executable directory';
