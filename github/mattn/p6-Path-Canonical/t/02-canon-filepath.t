use v6;
use Test;
use Path::Canonical;

plan 6;

unless $*DISTRO.is-win {
    skip-rest 'Windows-only tests';
    exit;
}
is canon-filepath('c:\\path/to/../from/file.txt'), 'c:\\path\\from\\file.txt';
is canon-filepath('c:/\\path/to/../..\\..//file.txt'), 'c:\\file.txt';
is canon-filepath('\\\\path/to/../from/file.txt'), '\\\\path\\to\\from\\file.txt';
is canon-filepath('\\\\path/to/../../file.txt'), '\\\\path\\to\\file.txt';
is canon-filepath('path/to/../file.txt'), '\\path\\file.txt';
is canon-filepath('path/to/../../file.txt'), '\\file.txt';
