use v6;

use Test;
plan 19;

use Parser::FreeXL::Native;

my Parser::FreeXL::Native $parser .= new;

isa-ok $parser.version, Str, 'got a version';

throws-like { $parser.open('not_existing.xls') }, FileNotFound, message => /not_existing\.xls/;

$parser.open('./t/test_files/basic.xls');

is $parser.sheet_count, 2, 'correct number of sheets';

throws-like { $parser.select_sheet(2) }, IllegalSheetIndex,
    message => "sheet with index: '2' does not exist";

$parser.select_sheet('sheet_2');

throws-like { $parser.select_sheet('not_existing_sheet') }, IllegalSheetName,
    message => "sheet with name: 'not_existing_sheet' does not exist";

$parser.select_sheet(0);

my ($rows, $cols) = $parser.sheet_dimensions;
is $cols, 2, 'col dimension correct';
is $rows, 4, 'row dimension correct';

throws-like { $parser.get_cell(10, 0); }, IllegalCell,
    message => "Cell in sheet: 'sheet_1', row: '10', col: '0' does not exist\n"
             ~ "Boundaries in sheet are rows: '4', cols: '2'";

my $str_cell = $parser.get_cell(0, 0);
is $str_cell.type,  'text',         'type of string cell correct';
is $str_cell.value, 'Hello World!', 'value of string cell correct';

my $date_cell = $parser.get_cell(0, 1);
is $date_cell.type,  'date',       'type of date cell correct';
is $date_cell.value, '1994-12-07', 'value of date cell correct';

my $time_cell = $parser.get_cell(1, 1);
is $time_cell.type,  'time',     'type of time cell correct';
is $time_cell.value, '12:04:00', 'value of time cell correct';

my $int_cell = $parser.get_cell(2, 1);
is $int_cell.type,  'int', 'type of int cell correct';
is $int_cell.value, '12',  'value of int cell correct';

my $double_cell = $parser.get_cell(3, 1);
is $double_cell.type,  'double', 'type of double cell correct';
is $double_cell.value, '0.13',  'value of double cell correct';

is $parser.sheet_names, <sheet_1 sheet_2>, 'names of sheets correct';
