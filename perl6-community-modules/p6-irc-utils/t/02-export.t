use v6;

use Test;
use IRC::Utils;

plan 17;

# Verify that the public-facing API is as it should be
ok(defined(&numeric_to_name),    'Check that numeric_to_name() is exported');
ok(defined(&name_to_numeric),    'Check that name_to_numeric() is exported');
ok(defined(&uc_irc),             'Check that uc_irc() is exported');
ok(defined(&lc_irc),             'Check that lc_irc() is exported');
ok(defined(&eq_irc),             'Check that eq_irc() is exported');
ok(defined(&parse_mode_line),    'Check that parse_mode_line() is exported');
ok(defined(&normalize_mask),     'Check that normalize_mask() is exported');
ok(defined(&unparse_mode_line),  'Check that unparse_mode_line() is exported');
ok(defined(&gen_mode_change),    'Check that gen_mode_change() is exported');
ok(defined(&is_valid_nick_name), 'Check that is_valid_nick_name() is exported');
ok(defined(&is_valid_chan_name), 'Check that is_valid_chan_name() is exported');
ok(defined(&matches_mask),       'Check that matches_mask() is exported');
ok(defined(&parse_user),         'Check that parse_user() is exported');
ok(defined(&has_color),          'Check that has_color() is exported');
ok(defined(&has_formatting),     'Check that has_formatting() is exported');
ok(defined(&strip_color),        'Check that strip_color() is exported');
ok(defined(&strip_formatting),   'Check that strip_formatting() is exported');

# vim: ft=perl6

