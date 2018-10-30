use v6;

use Test;
use IRC::Utils;

# TODO Organize tests so they're ordered the same way they are in source file
# TODO Add tests for color and formatting constants
# TODO Add test with casemapping for matches_mask()

plan *;

# Test numeric_to_name()
{
    my Int $code      = 332;
    my Str $rpl_topic = numeric_to_name($code);

    is $rpl_topic, 'RPL_TOPIC', 'Check numeric_to_name()';
}

# Test name_to_numeric()
{
    my Str $rpl_topic = 'RPL_TOPIC';
    my Int $code      = name_to_numeric($rpl_topic);

    is $code, 332, 'Check name_to_numeric()';
}

# Test uc_irc()
{
    my Str $nick    = '^{soh|cah|toa}^';
    my Str $uc_nick = uc_irc $nick;

    is $uc_nick,  '~[SOH\CAH\TOA]~', 'Check one arg uc_irc()';
}

{
    my Str $nick     = 'soh_cah_toa';
    my Str $uc_ascii = uc_irc $nick, 'ascii';

    is $uc_ascii, 'SOH_CAH_TOA', 'Check two arg uc_irc() with "ascii"';
}

{
    my Str $nick      = '{soh|cah|toa}';
    my Str $uc_strict = uc_irc $nick, 'strict-rfc1459';

    is $uc_strict,  '[SOH\CAH\TOA]', 'Check one arg uc_irc() with "strict-rfc1459"';
}

# Test lc_irc()
{
    my Str $nick    = '~[SOH\CAH\TOA]~';
    my Str $lc_nick = lc_irc $nick;

    is $lc_nick,  '^{soh|cah|toa}^', 'Check one arg lc_irc()';
}

{
    my Str $nick     = 'SOH_CAH_TOA';
    my Str $lc_ascii = lc_irc $nick, 'ascii';

    is $lc_ascii, 'soh_cah_toa', 'Check two arg lc_irc() with "ascii"';
}

{
    my Str $nick      = '[SOH\CAH\TOA]';
    my Str $lc_strict = lc_irc $nick, 'strict-rfc1459';

    is $lc_strict,  '{soh|cah|toa}', 'Check one arg lc_irc() with "strict-rfc1459"';
}

# Test eq_irc()
{
    my Str  $uc = '[S0H~C4H~T04]';
    my Str  $lc = '{s0h~c4h~t04}';
    my Bool $eq = eq_irc($uc, $lc);

    ok $eq, 'Check eq_irc()';
}

# Test is_valid_nick_name()
{
    my Str  $nick  = '{soh_cah_toa}';
    my Bool $valid = is_valid_nick_name($nick);

    ok $valid, 'Check is_valid_nick_name() with valid nickname';
}

{
    my Str  $nick  = '{soh=cah=toa}';
    my Bool $valid = is_valid_nick_name($nick);

    nok $valid, 'Check is_valid_nick_name() with invalid nickname';
}

# Test is_valid_chan_name()
{
    my Str  $chan  = '#foobar';
    my Bool $valid = is_valid_chan_name($chan);

    ok $valid, 'Check one arg is_valid_chan_name() with valid channel';
}

{
    my Str  $chan  = '#foo:bar';
    my Bool $valid = is_valid_chan_name($chan);

    nok $valid, 'Check one arg is_valid_chan_name() with invalid channel';
}

{
    my Str  $chan  = 'foobar';
    my Bool $valid = is_valid_chan_name($chan, ['&']);

    ok $valid, 'Check two arg is_valid_chan_name() with valid channel';
}

{
    my Str  $chan  = '#foo:bar';
    my Bool $valid = is_valid_chan_name($chan, ['#', '%']);

    nok $valid, 'Check two arg is_valid_chan_name() with invalid channel';
}

# Test parse_user()
{
    my Str $fqn                  = 'foo!bar@baz.net';
    my Str ($nick, $user, $host) = parse_user($fqn);

    is $nick, 'foo',     'Check parse_user() nickname';
    is $user, 'bar',     'Check parse_user() username';
    is $host, 'baz.net', 'Check parse_user() hostname';
}

# Test has_color()
{
    my Str  $color_msg = "\x0304,05This is a colored message\x03";
    my Bool $has_color = has_color($color_msg);

    ok $has_color, 'Check has_color() with colored message';
}

{
    my Str  $normal_msg = 'This is a normal message';
    my Bool $has_color  = has_color($normal_msg);

    nok $has_color, 'Check has_color() with normal message';
}

# Test has_formatting()
{
    my Str  $fmt_msg = "This message has \x1funderlined\x0f text";
    my Bool $has_fmt = has_formatting($fmt_msg);

    ok $has_fmt, 'Check has_formatting() with formatted text';
}

{
    my Str  $normal_msg = 'This message has no formatted text';
    my Bool $has_fmt    = has_formatting($normal_msg);

    nok $has_fmt, 'Check has_formatting() with normal text';
}

# Test strip_color()
{
    my Str $bg_color = "\x03,05Look at the pretty background colors!\x03";
    my Str $fg_color = "\x[03]05Look at the pretty foreground colors!\x03";

    my Str $bg_strip = strip_color($bg_color);
    my Str $fg_strip = strip_color($fg_color);

    is $bg_strip, 'Look at the pretty background colors!',
                  'Check strip_color() with colored background';

    is $fg_strip, 'Look at the pretty foreground colors!',
                  'Check strip_color() with colored foreground';
}

{
    my Str $normal_msg  = "Aw, I'm just a plain old boring message";
    my Str $strip       = strip_color($normal_msg);

    is $strip, "Aw, I'm just a plain old boring message",
               'Check strip_color() with normal message';
}

# Test normalize_mask()
{
    my Str $mask = normalize_mask('*@*');

    is $mask, '*!*@*', 'Check normalize_mask() with partial mask';
}

{
    my Str $mask = normalize_mask('foobar*');

    is $mask, 'foobar*!*@*', 'Check normalize_mask() with host mask';
}

{
    my Str $mask = normalize_mask('bazqux*!*@*');

    is $mask, 'bazqux*!*@*', 'Check normalize_mask() with full mask';
}

# TODO Get strip_formatting() tests working

# Test strip_formatting()
#
    #my Str $fmt_msg = 'This is \x02strong\x0f!';
    #my Str $fmt_msg = "This message has \x1funderlined\x0f text";
    #my Str $strip   = strip_formatting($fmt_msg);

    #is $strip, 'This is strong!',
               #'Check strip_formatting() with formatted text';
#

#
    #my Str $fmt_msg = 'Just a normal plain message';
    #my Str $strip   = strip_formatting($fmt_msg);

    #is $strip, 'Just a normal plain message',
               #'Check strip_formatting() with unformatted text';
#

# Test parse_mode_line()
{
    my %hash = parse_mode_line(<mi foo bar>);

    is %hash<modes>[0], '+m',  'Check parse_mode_line() with +m';
    is %hash<modes>[1], '+i',  'Check parse_mode_line() with +i';

    is %hash<args>[0],  'foo', "Check parse_mode_line() with 'foo' host";
    is %hash<args>[1],  'bar', "Check parse_mode_line() with 'bar' server";
}

{
    my %hash = parse_mode_line(qw/-b +b!*@*/);

    is %hash<modes>[0], '-b',     'Check parse_mode_line() with -b';
    is %hash<args>[0],  '+b!*@*', 'Check parse_mode_line() with +b!*@*';
}

{
    my %hash = parse_mode_line(qw/+b -b!*@*/);

    is %hash<modes>[0], '+b',     'Check parse_mode_line() with +b';
    is %hash<args>[0],  '-b!*@*', 'Check parse_mode_line() with -b!*@*';
}

# Test unparse_mode_line()
{
    my Str $mode     = '+m+m+m-i+i';
    my Str $unparsed = unparse_mode_line($mode);
    
    is $unparsed, '+mmm-i+i', 'Check unparse_mode_line() with valid mode line';
}

{
    my Str $mode     = '';
    my Str $unparsed = unparse_mode_line($mode);
    
    is $unparsed, '', 'Check unparse_mode_line() with invalid mode line';
}

# Test gen_mode_change()
{
    my Str $mode = gen_mode_change('i', 'ailowz');

    is $mode, '+alowz', 'Check gen_mode_change() to add modes';
}

{
    my Str $mode = gen_mode_change('ailowz', 'i');

    is $mode, '-alowz', 'Check gen_mode_change() to remove modes';
}

{
    my Str $mode = gen_mode_change('i', 'alowz');

    is $mode, '-i+alowz', 'Check gen_mode_change() to remove and add modes';
}

# Test matches_mask()
{
    my Str  $mask  = 'foobar*!*@*';
    my Str  $user  = 'foobar!baz@qux.net';
    my Bool $match = matches_mask($mask, $user);

    ok $match, 'Check matches_mask() with matching name, no mapping';
}

{
    my Str  $mask  = 'foobar*!*@*';
    my Str  $user  = 'blah!blah@blah.net';
    my Bool $match = matches_mask($mask, $user);

    nok $match, 'Check matches_mask() with non-matching name, no mapping';
}

done-testing;

# vim: ft=perl6

