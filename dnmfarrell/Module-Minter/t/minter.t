use Test;
use lib 'lib';
use File::Temp;

plan 22;

use Module::Minter; pass "use Module::Minter";

my $tmp_dir = tempdir;
ok my $root_filepath = mint-new-module("$tmp_dir/Super::Module::Mighty", 'David Farrell', 'FreeBSD'), "Mint new module: Super::Module::Mighty";
ok $root_filepath.IO ~~ :e, 'Root module directory exists';
ok $root_filepath.IO ~~ :d, 'Root module directory is a dir';
ok "$root_filepath/lib/Super/Module/Mighty.pm".IO ~~ :e, 'Main .pm file was created';
ok "$root_filepath/t/Mighty.t".IO ~~ :e, 'test file was created';
ok "$root_filepath/LICENSE".IO ~~ :e, 'LICENSE file was created';
ok "$root_filepath/META.info".IO ~~ :e, 'META file was created';

# illegal module names
dies_ok { mint-new-module('1::No::Leading:Numeric') }, 'dies on leading numeric';

# grammar - illegal
nok Module::Minter::Legal-Module-Name.parse('1Leading::Numeric'), 'illegal leading number';
nok Module::Minter::Legal-Module-Name.parse('Missing:Colon'), 'illegal missing colon';
nok Module::Minter::Legal-Module-Name.parse('Trailing::Colons::'),'illegal trailing colons';
nok Module::Minter::Legal-Module-Name.parse('Trailing::Colons::Nested::Deep::'),'illegal sub package trailing colons';
nok Module::Minter::Legal-Module-Name.parse('::Leading::Colons'), 'illegal leading colons';
nok Module::Minter::Legal-Module-Name.parse('Contains-Hyphen::Bad'), 'illegal contains hyphen';
nok Module::Minter::Legal-Module-Name.parse(''), 'illegal empty string';

# grammar - legal
ok Module::Minter::Legal-Module-Name.parse('Regular::Module'), 'Regular::Module';
ok Module::Minter::Legal-Module-Name.parse('Regular::Module::Nested::Sub::Package'), 'Regular::Module::Nested::Sub::Package';
ok Module::Minter::Legal-Module-Name.parse('_Leading::Underscore'), '_Leading::Underscore';
ok Module::Minter::Legal-Module-Name.parse('V::S'), 'V::S';
ok Module::Minter::Legal-Module-Name.parse('v::Lowercase::Beginning'), 'v::Lowercase::Beginning';
ok Module::Minter::Legal-Module-Name.parse('Perl6::Alpha::Numer1c'), 'Perl6::Alpha::Numer1c';

my $matches = Module::Minter::Legal-Module-Name.parse('Perl6::Alpha::Numer1c');
say $matches<identifier>[0].Str;


