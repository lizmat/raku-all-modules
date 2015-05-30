# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

unit module IRC::Utils:<soh_cah_toa 0.2.0>;

=begin pod

=head1 NAME

IRC::Utils - handy IRC utilities for use in other IRC-related modules

=head1 SYNOPSIS

=begin code

    use v6;
    use IRC::Utils;

    my Str $nick    = '[foo]^BAR^[baz]';
    my Str $uc_nick = uc_irc($nick);
    my Str $lc_nick = lc_irc($nick);

    # Check equivalence of two nicknames
    if eq_irc($uc_nick, $lc_nick) {
        say "These nicknames are the same!";
    }

    # Check if nickname conforms to RFC1459
    if is_valid_nick_name($nick) {
        say "Nickname is valid!";
    }

=end code

=head1 DESCRIPTION

The C<IRC::Utils> module provides a procedural interface for performing many
common IRC-related tasks such as comparing nicknames, changing user modes,
normalizing ban masks, etc. It is meant to be used as a base module for
creating other IRC-related modules.

Internet Relay Chat (IRC) is a teleconferencing system used for real-time
Internet chatting and conferencing. It is primarily used for group communication
but also allows private one-to-one messages. The protocol is published in
RFC 1459 <https://www.rfc-editor.org/rfc/rfc1459.txt>.

=head1 SUBROUTINES

Unlike the C<IRC::Utils> module for Perl 5, you do not need to specify the
C<:ALL> tag when importing the module. Therefore, the following subroutines
are exported into the caller's namespace by default.

=over 4

=item B<uc_irc(Str $value, Str $type?)>

Converts a string to uppercase that conforms to the allowable characters as
defined by RFC 1459.

The C<$value> parameter represents the string to convert to uppercase.

The C<$type> parameter is an optional string that represents C<$value>'s
casemapping. It can be 'rfc1459', 'strict-rfc1459', or 'ascii'. If not given,
it defaults to 'rfc1459'.

Returns the value of C<$value> converted to uppercase according to C<$type>.

Example:

=begin code

    my Str $uc_hello = uc_irc('Hello world!');

    say $hello;
    # Output: HELLO WORLD!

=end code

=item B<lc_irc(Str $value, Str $type?)>

Converts a string to lowercase that conforms to the allowable characters as
defined by RFC 1459.

The C<$value> parameter represents the string to convert to lowercase.

The C<$type> parameter is an optional string that represents C<$value>'s
casemapping. It can be 'rfc1459', 'strict-rfc1459', or 'ascii'. If not given,
it defaults to 'rfc1459'.

Returns the value of C<$value> converted to lowercase according to C<$type>.

Example:

=begin code

    my Str $lc_hello = lc_irc('HELLO WORLD!');

    say $lc_irc;
    # Output: hello world!

=end code

=item B<eq_irc(Str $first, Str $second, Str $type?)>

Checks the equivalence of two strings that conform to the allowable characters
as defined by RFC 1459.

The C<$first> parameter is the first string to compare.

The C<$second> parameter is the second string to compare.

The C<$type> parameter is an optional string that represents the casemapping of
C<$first> and C<$second>. It can be 'rfc1459', 'strict-rfc1459', or 'ascii'. If
not given, it defaults to 'rfc1459'.

Returns C<Bool::True> if the two strings are equivalent and C<Bool::False>
otherwise.

Example:

=begin code

    my Str  $upper = '[F00~B4R~B4Z]';
    my Str  $lower = '{f00~b4r~b4z}';
    my Bool $equal =  eq_irc();

    say 'They're equal!' if $equal;
    # Output: They're equal!

=end code

=item B<parse_mode_line(@mode)>

Parses a list representing an IRC status mode line.

The C<@mode> parameter is an array representing the status mode line to parse.
You may also pass an array or hash to specify valid channel and status modes.
If not given, the valid channel modes default to C<< <beI k l imnpstaqr> >> and
the valid status modes default to C<< {o => '@', h => '%', v => '+'} >>.

Returns a hash containing two keys: C<modes> and C<args>. The C<modes> key is an
array of normalized modes. The C<args> key is an array that represents the
relevant arguments to the modes in C<modes>.

If for any reason the mode line in C<@mode> can not be parsed, a C<Nil> hash
will be returned.

Example:

=begin code

    my %hash = parse_mode_line(<ov foo bar>);    

    say %hash<modes>[0];
    # Output: +o

    say %hash<modes>[1];
    # Output: +v

    say %hash<args>[0];
    # Output: foo

    say %hash<args>[1];
    # Output: bar
=end code

=item B<normalize_mask(Str $mask)>

Fully qualifies or "normalizes" an IRC host/server mask.

The C<$mask> argument is a string representing a host/server mask.

Returns C<$mask> as a fully qualified mask.

Example:

=begin code

    my Str $mask = normalize_mask('*@*');

    say $mask;
    # Output: *!*@*

=end code

=item B<numeric_to_name(Int $code)>

Converts an IRC reply or error code to its corresponding string representation.
This includes all values defined by RFC 1459 and also a few network-specific
extensions.

The C<$code> parameter is an integer representing the numeric code to convert.
For instance, 461 which is C<ERR_NEEDMOREPARAMS>.

Returns the string representation of C<$code>.

Example:

=begin code

    my Str $topic = numeric_to_name(332);

    say $topic;
    # Output: RPL_TOPIC

=end code

=item B<name_to_numeric(Str $name)>

Converts a string representation of an IRC reply or error code into its
corresponding numeric code. This includes all values defined by RFC 1459 and
also a few network-specific extensions.

The C<$name> parameter is a string representing the reply or error code. For
instance, C<ERR_NEEDMOREPARAMS> is 461.

Returns the numerical representation of C<$name>.

Example:

=begin code

    my Int $topic name_to_numeric('RPL_TOPIC');

    say $topic;
    # Output: 332

=end code

=item B<is_valid_nick_name(Str $nick)>

Checks if an IRC nickname is valid. That is, it conforms to the allowable
characters defined in RFC 1459.

The C<$nick> parameter is a string representing the nickname to validate.

Returns C<Bool::True> if C<$nick> is a valid IRC nickname and C<Bool::False>
otherwise.

Example:

=begin code

    my Bool $valid_nick = is_valid_nick_name('{foo_bar_baz}');

    say 'Nickname is valid!' if $valid_nick;
    # Output: Nickname is valid!

=end code

=item B<is_valid_chan_name(Str $chan, Str @types?)>

Checks if an IRC channel name is valid. That is, it conforms to the allowable
characters defined in RFC 1459.

The C<$chan> parameter is a string representing the channel name to check.

The C<@types> parameter is an optional anonymous list of channel types. For
instance, '#'. If not given, it defaults to C<['#', '&']>.

Returns C<Bool::True> if C<$nick> is a valid IRC channel name and C<Bool::False>
otherwise.

Example:

=begin code

    my Bool $valid_chan = is_valid_chan_name('#foobar');

    say 'Channel name is valid!' if $valid_chan;    
    # Output: Channel name is valid!

=end code

=item B<unparse_mode_line(Str $line)>

Condenses or "unparses" an IRC mode line.

The C<$line> parameter is a string representing an arbitrary number of mode
changes.

Returns the condensed version of C<$line> as a string.

Example:

=begin code

    my Str $mode = unparse_mode_line('+m+m+m-i+i');

    say $mode;
    # Output: +mmm-i+i

=end code

=head2 C<gen_mode_change(Str $before, Str $after)>

Determines the changes made between two IRC user modes.

The C<$before> parameter is a string representing the user mode before the
change.

The C<$after> parameter is a string representing the user mode after the
change.

Returns a string representing the modes that changed between C<$before> and
C<$after>. That is, any modes that were added or removed from C<$before> to
create C<$after>.

Example:

=begin code

    my Str $mode_change = gen_mode_change('abcde', 'befmZ');

    say $mode_change;
    # Output: -acd+fmZ

=end code

=item B<matches_mask(Str $mask, Str $match, Str $mapping?)>

Determines whether a particular user/server matches an IRC mask.

The C<$mask> parameter is a string representing the IRC mask to match against.

The C<$match> parameter is a string representing the user/server to check.

The C<$mapping> parameter is an optional string that specifies which
casemapping to use for C<$mask> and C<$match>. It can be 'rfc1459',
'strict-rfc1459', or 'ascii'. If not given, it defaults to 'rfc1459'.

Example:

=begin code

    my Str  $banmask = 'foobar*!*@*';
    my Str  $user    = 'foobar!baz@qux.net';
    my Bool $matches = matches_mask($banmask, $user);

    say "The user $user is banned" if $matches;
    # Output: The user foobar!baz@qux.net is banned

=end code

=item B<parse_user(Str $user)>

Parses a fully-qualified IRC username and splits it into the parts representing
the nickname, username, and hostname.

The C<$user> parameter is a string representing the fully-qualified username to
parse. It must be of the form C<nick!user@host>.

Returns a list containing the nickname, username, and hostname parts of
C<$user>.

Example:

=begin code

    my Str ($nick, $user, $host) = parse_user('foo!bar@baz.net');

    say $nick
    # Output: foo

    say $user
    # Output: bar

    say $host
    # Output: baz.net

=end code

=item B<has_color(Str $string)>

Checks if a string contains any embedded color codes.

The C<$string> parameter is the string to check.

Returns C<Bool::True> if C<$string> contains any embedded color codes and
C<Bool::False> otherwise.

Example:

=begin code

    my Bool $color = has_color("\x0304,05This is a colored message\x03");

    say 'Oh, pretty colors!' if $color;
    # Output: Oh, pretty colors!

=end code

=item B<has_formatting(Str $string)>

Checks if a string contains any embedded text formatting codes.

The C<$string> parameter is the string to check.

Returns C<Bool::True> if C<$string> contains any embedded formatting codes and
C<Bool::False> otherwise.

Example:

=begin code

    my Bool $fmt_text = has_formatting("This message has \x1funderlined\x0f text");

    say 'I got some formatted text!' if $fmt_text;
    # Output: I got some formatted text!

=end code

=item B<strip_color(Str $string)>

Strips a string of all embedded color codes (if any).

The C<$string> parameter is the string to strip.

Returns the string given in C<$string> with all embedded color codes removed.
If the given string does not contain any color codes, the original string is
returned as is.

Example:

=begin code

    my Str $stripped = strip_color("\x03,05Look at the pretty colors!\x03");

    say $stripped;
    # Output: Look at the pretty colors!

=end code

=item B<strip_formatting(Str $string)>

Strips a string of all embedded text formatting codes (if any).

The C<$string> parameter is the string to strip.

Returns the string given in C<$string> with all embedded text formatting codes
removed. If the given string does not contain any text formatting codes, the
original string is returned as is.

Example:

=begin code

    my Str $stripped = strip_formatting('This is \x02strong\x0f!");

    say $stripped;
    # Output: This is strong!

=end code

=back

=head1 CONSTANTS

The following constants are provided to embed color and formatting codes in IRC
messages.

=over 4

=item Normal text:

    NORMAL

=item Formatting:

    BOLD
    UNDERLINE
    REVERSE
    ITALIC
    FIXED

=item Colors:

    WHITE
    BLACK
    BLUE
    GREEN
    RED
    BROWN
    PURPLE
    ORANGE
    YELLOW
    LIGHT_GREEN
    TEAL
    LIGHT_CYAN
    LIGHT_BLUE
    PINK
    GREY
    LIGHT_GREY

=back

To terminate a single formatting code, you must use its respective constant.
Additionally, you may use the C<NORMAL> constant to terminate I<all> formatting
codes (including colors).

Conversely, a single color code must be terminated with the C<NORMAL> constant.
However, this has the side effect of also terminating any other formatting
codes.

Example:

=begin code

    my Str $foo = 'Oh hai! I haz ' ~ GREEN ~ 'green ' ~ NORMAL ~ 'text!';
    my Str $bar = BOLD ~ UNDERLINE ~ 'K thx bye!' ~ NORMAL;

=end code

=end pod

# TODO Add declaractor blocks when Rakudo supports them
# TODO Use comb/join hack to get around unsupported escapes in character classes

our $NORMAL      = "\x0f";

# Text formats
our $BOLD        = "\x02";
our $UNDERLINE   = "\x1f";
our $REVERSE     = "\x16";
our $ITALIC      = "\x1d";
our $FIXED       = "\x11";
our $BLINK       = "\x06";

# Color formats
our $WHITE       = "\x0300";
our $BLACK       = "\x0301";
our $BLUE        = "\x0302";
our $GREEN       = "\x0303";
our $RED         = "\x0304";
our $BROWN       = "\x0305";
our $PURPLE      = "\x0306";
our $ORANGE      = "\x0307";
our $YELLOW      = "\x0308";
our $LIGHT_GREEN = "\x0309";
our $TEAL        = "\x0310";
our $LIGHT_CYAN  = "\x0311";
our $LIGHT_BLUE  = "\x0312";
our $PINK        = "\x0313";
our $GREY        = "\x0314";
our $LIGHT_GREY  = "\x0315";

# Associates numeric codes with their string representation
our %NUMERIC2NAME =
   1 => 'RPL_WELCOME',           # RFC2812
   2 => 'RPL_YOURHOST',          # RFC2812
   3 => 'RPL_CREATED',           # RFC2812
   4 => 'RPL_MYINFO',            # RFC2812
   5 => 'RPL_ISUPPORT',          # draft-brocklesby-irc-isupport-03
   8 => 'RPL_SNOMASK',           # Undernet
   9 => 'RPL_STATMEMTOT',        # Undernet
   10 => 'RPL_STATMEM',           # Undernet
   20 => 'RPL_CONNECTING',        # IRCnet
   14 => 'RPL_YOURCOOKIE',        # IRCnet
   42 => 'RPL_YOURID',            # IRCnet
   43 => 'RPL_SAVENICK',          # IRCnet
   50 => 'RPL_ATTEMPTINGJUNC',    # aircd
   51 => 'RPL_ATTEMPTINGREROUTE', # aircd
   200 => 'RPL_TRACELINK',         # RFC1459
   201 => 'RPL_TRACECONNECTING',   # RFC1459
   202 => 'RPL_TRACEHANDSHAKE',    # RFC1459
   203 => 'RPL_TRACEUNKNOWN',      # RFC1459
   204 => 'RPL_TRACEOPERATOR',     # RFC1459
   205 => 'RPL_TRACEUSER',         # RFC1459
   206 => 'RPL_TRACESERVER',       # RFC1459
   207 => 'RPL_TRACESERVICE',      # RFC2812
   208 => 'RPL_TRACENEWTYPE',      # RFC1459
   209 => 'RPL_TRACECLASS',        # RFC2812
   210 => 'RPL_STATS',             # aircd
   211 => 'RPL_STATSLINKINFO',     # RFC1459
   212 => 'RPL_STATSCOMMANDS',     # RFC1459
   213 => 'RPL_STATSCLINE',        # RFC1459
   214 => 'RPL_STATSNLINE',        # RFC1459
   215 => 'RPL_STATSILINE',        # RFC1459
   216 => 'RPL_STATSKLINE',        # RFC1459
   217 => 'RPL_STATSQLINE',        # RFC1459
   218 => 'RPL_STATSYLINE',        # RFC1459
   219 => 'RPL_ENDOFSTATS',        # RFC1459
   221 => 'RPL_UMODEIS',           # RFC1459
   231 => 'RPL_SERVICEINFO',       # RFC1459
   233 => 'RPL_SERVICE',           # RFC1459
   234 => 'RPL_SERVLIST',          # RFC1459
   235 => 'RPL_SERVLISTEND',       # RFC1459
   239 => 'RPL_STATSIAUTH',        # IRCnet
   241 => 'RPL_STATSLLINE',        # RFC1459
   242 => 'RPL_STATSUPTIME',       # RFC1459
   243 => 'RPL_STATSOLINE',        # RFC1459
   244 => 'RPL_STATSHLINE',        # RFC1459
   245 => 'RPL_STATSSLINE',        # Bahamut, IRCnet, Hybrid
   250 => 'RPL_STATSCONN',         # ircu, Unreal
   251 => 'RPL_LUSERCLIENT',       # RFC1459
   252 => 'RPL_LUSEROP',           # RFC1459
   253 => 'RPL_LUSERUNKNOWN',      # RFC1459
   254 => 'RPL_LUSERCHANNELS',     # RFC1459
   255 => 'RPL_LUSERME',           # RFC1459
   256 => 'RPL_ADMINME',           # RFC1459
   257 => 'RPL_ADMINLOC1',         # RFC1459
   258 => 'RPL_ADMINLOC2',         # RFC1459
   259 => 'RPL_ADMINEMAIL',        # RFC1459
   261 => 'RPL_TRACELOG',          # RFC1459
   262 => 'RPL_TRACEEND',          # RFC2812
   263 => 'RPL_TRYAGAIN',          # RFC2812
   265 => 'RPL_LOCALUSERS',        # aircd, Bahamut, Hybrid
   266 => 'RPL_GLOBALUSERS',       # aircd, Bahamut, Hybrid
   267 => 'RPL_START_NETSTAT',     # aircd
   268 => 'RPL_NETSTAT',           # aircd
   269 => 'RPL_END_NETSTAT',       # aircd
   270 => 'RPL_PRIVS',             # ircu
   271 => 'RPL_SILELIST',          # ircu
   272 => 'RPL_ENDOFSILELIST',     # ircu
   300 => 'RPL_NONE',              # RFC1459
   301 => 'RPL_AWAY',              # RFC1459
   302 => 'RPL_USERHOST',          # RFC1459
   303 => 'RPL_ISON',              # RFC1459
   305 => 'RPL_UNAWAY',            # RFC1459
   306 => 'RPL_NOWAWAY',           # RFC1459
   307 => 'RPL_WHOISREGNICK',      # Bahamut, Unreal, Plexus
   310 => 'RPL_WHOISMODES',        # Plexus
   311 => 'RPL_WHOISUSER',         # RFC1459
   312 => 'RPL_WHOISSERVER',       # RFC1459
   313 => 'RPL_WHOISOPERATOR',     # RFC1459
   314 => 'RPL_WHOWASUSER',        # RFC1459
   315 => 'RPL_ENDOFWHO',          # RFC1459
   317 => 'RPL_WHOISIDLE',         # RFC1459
   318 => 'RPL_ENDOFWHOIS',        # RFC1459
   319 => 'RPL_WHOISCHANNELS',     # RFC1459
   321 => 'RPL_LISTSTART',         # RFC1459
   322 => 'RPL_LIST',              # RFC1459
   323 => 'RPL_LISTEND',           # RFC1459
   324 => 'RPL_CHANNELMODEIS',     # RFC1459
   325 => 'RPL_UNIQOPIS',          # RFC2812
   328 => 'RPL_CHANNEL_URL',       # Bahamut, AustHex
   329 => 'RPL_CREATIONTIME',      # Bahamut
   330 => 'RPL_WHOISACCOUNT',      # ircu
   331 => 'RPL_NOTOPIC',           # RFC1459
   332 => 'RPL_TOPIC',             # RFC1459
   333 => 'RPL_TOPICWHOTIME',      # ircu
   338 => 'RPL_WHOISACTUALLY',     # Bahamut, ircu
   340 => 'RPL_USERIP',            # ircu
   341 => 'RPL_INVITING',          # RFC1459
   342 => 'RPL_SUMMONING',         # RFC1459
   345 => 'RPL_INVITED',           # GameSurge
   346 => 'RPL_INVITELIST',        # RFC2812
   347 => 'RPL_ENDOFINVITELIST',   # RFC2812
   348 => 'RPL_EXCEPTLIST',        # RFC2812
   349 => 'RPL_ENDOFEXCEPTLIST',   # RFC2812
   351 => 'RPL_VERSION',           # RFC1459
   352 => 'RPL_WHOREPLY',          # RFC1459
   353 => 'RPL_NAMREPLY',          # RFC1459
   354 => 'RPL_WHOSPCRPL',         # ircu
   355 => 'RPL_NAMREPLY_',         # QuakeNet
   361 => 'RPL_KILLDONE',          # RFC1459
   362 => 'RPL_CLOSING',           # RFC1459
   363 => 'RPL_CLOSEEND',          # RFC1459
   364 => 'RPL_LINKS',             # RFC1459
   365 => 'RPL_ENDOFLINKS',        # RFC1459
   366 => 'RPL_ENDOFNAMES',        # RFC1459
   367 => 'RPL_BANLIST',           # RFC1459
   368 => 'RPL_ENDOFBANLIST',      # RFC1459
   369 => 'RPL_ENDOFWHOWAS',       # RFC1459
   371 => 'RPL_INFO',              # RFC1459
   372 => 'RPL_MOTD',              # RFC1459
   373 => 'RPL_INFOSTART',         # RFC1459
   374 => 'RPL_ENDOFINFO',         # RFC1459
   375 => 'RPL_MOTDSTART',         # RFC1459
   376 => 'RPL_ENDOFMOTD',         # RFC1459
   381 => 'RPL_YOUREOPER',         # RFC1459
   382 => 'RPL_REHASHING',         # RFC1459
   383 => 'RPL_YOURESERVICE',      # RFC2812
   384 => 'RPL_MYPORTIS',          # RFC1459
   385 => 'RPL_NOTOPERANYMORE',    # AustHex, Hybrid, Unreal
   391 => 'RPL_TIME',              # RFC1459
   392 => 'RPL_USERSSTART',        # RFC1459
   393 => 'RPL_USERS',             # RFC1459
   394 => 'RPL_ENDOFUSERS',        # RFC1459
   395 => 'RPL_NOUSERS',           # RFC1459
   396 => 'RPL_HOSTHIDDEN',        # Undernet
   401 => 'ERR_NOSUCHNICK',        # RFC1459
   402 => 'ERR_NOSUCHSERVER',      # RFC1459
   403 => 'ERR_NOSUCHCHANNEL',     # RFC1459
   404 => 'ERR_CANNOTSENDTOCHAN',  # RFC1459
   405 => 'ERR_TOOMANYCHANNELS',   # RFC1459
   406 => 'ERR_WASNOSUCHNICK',     # RFC1459
   407 => 'ERR_TOOMANYTARGETS',    # RFC1459
   408 => 'ERR_NOSUCHSERVICE',     # RFC2812
   409 => 'ERR_NOORIGIN',          # RFC1459
   411 => 'ERR_NORECIPIENT',       # RFC1459
   412 => 'ERR_NOTEXTTOSEND',      # RFC1459
   413 => 'ERR_NOTOPLEVEL',        # RFC1459
   414 => 'ERR_WILDTOPLEVEL',      # RFC1459
   415 => 'ERR_BADMASK',           # RFC2812
   421 => 'ERR_UNKNOWNCOMMAND',    # RFC1459
   422 => 'ERR_NOMOTD',            # RFC1459
   423 => 'ERR_NOADMININFO',       # RFC1459
   424 => 'ERR_FILEERROR',         # RFC1459
   425 => 'ERR_NOOPERMOTD',        # Unreal
   429 => 'ERR_TOOMANYAWAY',       # Bahamut
   430 => 'ERR_EVENTNICKCHANGE',   # AustHex
   431 => 'ERR_NONICKNAMEGIVEN',   # RFC1459
   432 => 'ERR_ERRONEUSNICKNAME',  # RFC1459
   433 => 'ERR_NICKNAMEINUSE',     # RFC1459
   436 => 'ERR_NICKCOLLISION',     # RFC1459
   439 => 'ERR_TARGETTOOFAST',     # ircu
   440 => 'ERR_SERCVICESDOWN',     # Bahamut, Unreal
   441 => 'ERR_USERNOTINCHANNEL',  # RFC1459
   442 => 'ERR_NOTONCHANNEL',      # RFC1459
   443 => 'ERR_USERONCHANNEL',     # RFC1459
   444 => 'ERR_NOLOGIN',           # RFC1459
   445 => 'ERR_SUMMONDISABLED',    # RFC1459
   446 => 'ERR_USERSDISABLED',     # RFC1459
   447 => 'ERR_NONICKCHANGE',      # Unreal
   449 => 'ERR_NOTIMPLEMENTED',    # Undernet
   451 => 'ERR_NOTREGISTERED',     # RFC1459
   455 => 'ERR_HOSTILENAME',       # Unreal
   459 => 'ERR_NOHIDING',          # Unreal
   460 => 'ERR_NOTFORHALFOPS',     # Unreal
   461 => 'ERR_NEEDMOREPARAMS',    # RFC1459
   462 => 'ERR_ALREADYREGISTRED',  # RFC1459
   463 => 'ERR_NOPERMFORHOST',     # RFC1459
   464 => 'ERR_PASSWDMISMATCH',    # RFC1459
   465 => 'ERR_YOUREBANNEDCREEP',  # RFC1459
   466 => 'ERR_YOUWILLBEBANNED',   # RFC1459
   467 => 'ERR_KEYSET',            # RFC1459
   469 => 'ERR_LINKSET',           # Unreal
   471 => 'ERR_CHANNELISFULL',     # RFC1459
   472 => 'ERR_UNKNOWNMODE',       # RFC1459
   473 => 'ERR_INVITEONLYCHAN',    # RFC1459
   474 => 'ERR_BANNEDFROMCHAN',    # RFC1459
   475 => 'ERR_BADCHANNELKEY',     # RFC1459
   476 => 'ERR_BADCHANMASK',       # RFC2812
   477 => 'ERR_NOCHANMODES',       # RFC2812
   478 => 'ERR_BANLISTFULL',       # RFC2812
   481 => 'ERR_NOPRIVILEGES',      # RFC1459
   482 => 'ERR_CHANOPRIVSNEEDED',  # RFC1459
   483 => 'ERR_CANTKILLSERVER',    # RFC1459
   484 => 'ERR_RESTRICTED',        # RFC2812
   485 => 'ERR_UNIQOPPRIVSNEEDED', # RFC2812
   488 => 'ERR_TSLESSCHAN',        # IRCnet
   491 => 'ERR_NOOPERHOST',        # RFC1459
   492 => 'ERR_NOSERVICEHOST',     # RFC1459
   493 => 'ERR_NOFEATURE',         # ircu
   494 => 'ERR_BADFEATURE',        # ircu
   495 => 'ERR_BADLOGTYPE',        # ircu
   496 => 'ERR_BADLOGSYS',         # ircu
   497 => 'ERR_BADLOGVALUE',       # ircu
   498 => 'ERR_ISOPERLCHAN',       # ircu
   501 => 'ERR_UMODEUNKNOWNFLAG',  # RFC1459
   502 => 'ERR_USERSDONTMATCH',    # RFC1459
   503 => 'ERR_GHOSTEDCLIENT';     # Hybrid

# Associates string representation with their numeric codes
our %NAME2NUMERIC;

{
    my Int @keys  = map { +$_ }, %NUMERIC2NAME.keys;
    my Str @vals  = %NUMERIC2NAME.values;

    %NAME2NUMERIC = @vals Z @keys;
}

sub numeric_to_name(Int $code) returns Str is export {
    return %NUMERIC2NAME{$code};
}

sub name_to_numeric(Str $name) returns Int is export {
    return %NAME2NUMERIC{$name}.Int;
}

sub uc_irc(Str $value is copy, Str $type = 'rfc1459') returns Str is export {
    given ($type // '').lc {
        when 'ascii' {
            $value.=trans('a..z' => 'A..Z');
        }

        when 'strict-rfc1459' {
            $value.=trans('a..z{}|' => 'A..Z[]\\');
        }

        default {
            $value.=trans('a..z{}|^' => 'A..Z[]\\~');
        }
    }

    return $value;
}

sub lc_irc(Str $value is copy, Str $type = 'rfc1459') returns Str is export {
    given $type.lc {
        when 'ascii' {
            $value.=trans('A..Z' => 'a..z');
        }

        when 'strict-rfc1459' {
            $value.=trans('A..Z[]\\' => 'a..z{}|');
        }

        default {
            $value.=trans('A..Z[]\\~' => 'a..z{}|^');
        }
    }

    return $value;
}

sub eq_irc(Str $first, Str $second, Str $type = 'rfc1459') returns Bool is export {
    return Bool::False if !$first.defined || !$second.defined;

    return lc_irc($first, $type) eq lc_irc($second, $type) ?? Bool::True !! Bool::False;
}

# TODO @mode should be slurpy but for some reason it doesn't work right

sub parse_mode_line(@mode is copy) returns Hash is export {
    @mode = @mode.list;
    my @chan_modes = <beI k l imnpstaqr>;
    my $stat_modes = 'ohv';
    my %hash;
    my $count      = 0;

    while my $arg = @mode.shift {
        if $arg.WHAT.perl eq 'Array' {
            @chan_modes = $arg;
            next;
        }
        elsif $arg.WHAT.perl eq 'Hash' {
            $stat_modes = join '', $arg.keys;
            next;
        }
        elsif ($arg ~~ /^<[\- +]>/ or $count == 0) {
            my $action = '+';

            for $arg.comb -> $c {
                if $c eq '+' | '-' {
                    $action = $c;
                }
                else {
                    %hash.push('modes' => $action ~ $c);
                }

                if @chan_modes[0].elems
                    && @chan_modes[1].elems
                    && $stat_modes.elems {

                    # This is a really ugly way of getting around the fact
                    # that variable interpolation in character classes is
                    # now illegal in Perl 6. Imagine this as if it were:
                    #
                    # $c ~~ /<[$stat_modes @chan_modes[0] @chan_modes[1]]>/

                    my @a = @chan_modes[0..1].join('').comb;

                    %hash.push('args' => @mode.shift)
                        if $c ~~ ($stat_modes.comb | any(@a));
                }

                if @chan_modes[2].elems
                    && $action eq '+'
                    && $c ~~ (any(@chan_modes[2].join.comb)) {

                    %hash.push('args' => @mode.shift)
                }
            }
        }
        else {
            %hash.push('args' => $arg);
        }

        $count++;
    }

    return %hash;
}

sub normalize_mask(Str $mask is copy) returns Str is export {
    my @normalized;
    my $remainder;

    $mask.subst(/'*'**2..*/, '*', :g);

    if $mask !~~ /'!'/ and $mask ~~ /'@'/ {
        $remainder     = $mask;
        @normalized[0] = '*';
    }
    else {
        (@normalized[0], $remainder) = $mask.split('!', 2);
    }

    $remainder.subst('!', '', :g) if $remainder.defined;

    @normalized[1..2] = $remainder.split('@', 2) if $remainder.defined;
    @normalized[2].subst('@', '', :g)            if @normalized[2].defined;

    for 1..2 -> $i {
        @normalized[$i] = '*' if !@normalized[$i].defined;
    }

    return [~] @normalized[0], '!', @normalized[1], '@', @normalized[2];
}

sub unparse_mode_line(Str $line) returns Str is export {
    return '' if !$line.chars;

    my $action;
    my $return;

    for $line.split('') -> $mode {
        if $mode ~~ /^ [ '+' | '-' ] $/ && (!$action.defined || $mode ne $action) {
            $return ~= $mode;
            $action  = $mode;

            next;
        }

        # TODO I should be able to write `if $mode ne all('+', '-')` but
        #      for some reason I can't. Though it does work with any()

        $return ~= $mode if $mode ne '+' and $mode ne '-';
    }

    return $return.subst(/<[+ \-]> $/, /<?>/);
}

sub gen_mode_change(Str $before is copy, Str $after is copy) returns Str is export {
    $before = '' if !$before.defined;
    $after  = '' if !$after.defined;

    my $string = '';
    $string   ~= [~] _diff($before.split(''), $after.split(''));

    return unparse_mode_line($string);
}

sub is_valid_nick_name(Str $nick) returns Bool is export {
    #my regex complex {  _ \` \- \^ \| \\ \{\} \[\] };
    #my regex complex { '_' '`' '-' '|' '\\' '{' '}' '[' ']' };

    # TODO Get 'complex' regex to interpolate properly to reduce duplication
    # TODO Add backslash to regex

    return $nick ~~ /^ <[A..Z a..z      _ \- ` ^ | \{\} \[\]]>
                       <[A..Z a..z 0..9 _ \- ` ^ | \{\} \[\]]>* $/
        ?? Bool::True !! Bool::False;
}

# TODO Modify this to take just one arg and move #/& check into one regex b/c
#      even though this is how the Perl 5 IRC::Utils works, I don't like it

sub is_valid_chan_name(Str $chan, $types = ['#', '&']) returns Bool is export {
    return Bool::False if $types.chars == 0;
    return Bool::False if $chan.chars  >  200;
    return Bool::False if $types ~~ /^ <-[ # & ]> $/;

    for $types -> $t {
        my $c = $t ~ $chan;

        # Channels can't contain whitespace, commas, colons, null, or newlines
        return Bool::False if $c !~~ /^ $t <-[ \s \c07 \c0 \c012 \c015 , :]>+ $/;
    }

    return Bool::True;
}

sub matches_mask(Str $mask is copy, Str $match is copy, Str $mapping? is copy) is export {
    my $umask = uc_irc($mask, $mapping);

    # TODO Use better regex since <print> includes forbidden characters
    $umask.=subst('*', '.*', :g);
    $umask.=subst('?', '.', :g);

    # Escape metacharacters
    $umask.=subst('!', '\!', :g);
    #$match.=subst('!', '\!', :g);
    $umask.=subst('@', '\@', :g);
    #$match.=subst('@', '\@', :g);

    $match = uc_irc($match, $mapping);

    return $match ~~ /^ <$umask> $/ ?? Bool::True !! Bool::False;
}

sub parse_user(Str $user) returns List is export {
    return $user.split(/<[!@]>/);
}

sub has_color(Str $string) returns Bool is export {
    return $string ~~ /<[\x03 \x04 \x1b]>/ ?? Bool::True !! Bool::False;
}

# TODO Create rule/regex for matching format codes to reduce duplication
#      in has_formatting() and strip_formatting()

sub has_formatting(Str $string) returns Bool is export {
    return $string ~~ /<[\x02 \x1f \x16 \x1d \x11 \x06]>/
        ?? Bool::True
        !! Bool::False;
}

sub strip_color(Str $string is copy) returns Str is export {
    # Strip mIRC colors
    $string ~~ s:g/\x03 [\, \d**1..2 | \d**1..2 [\, \d**1..2]?]?//;

    # Strip other colors supported by certain clients
    $string ~~ s:g:i/\x04 <[0..9 a..f A..F]>**0..6//;

    # Strip ANSI escape codes
    $string ~~ s:g/\x1b \[ .*? <[\x00..\x1f \x40..\x7e]>//;

    # Strip terminating \x0f only if there aren't any formatting codes
    $string ~~ s:g/\x0f// if !has_formatting($string);

    return $string;
}

sub strip_formatting(Str $string is copy) returns Str is export {
    $string ~~ s:g/<[\c017 \c02 \c037 \c026 \c035 \c021 \c06]>//;
    #$string ~~ s:g/<[\x0f \x02 \x1f \x16 \x1d \x11 \x06]>//;

    # Strip terminating \x0f only if there aren't any color codes
    $string ~~ s:g/<[\017]>// if !has_color($string);
    #$string ~~ s:g/\x0f// if !has_color($string);

    return $string;
}

sub _diff(@before, @after) returns Array {
    my %in_before;
    my %in_after;

    my @diff;
    my %seen;

    %in_before{"$_"} = () for @before;
    %in_after{"$_"}  = () for @after;

    for @before -> $b {
        next if (%seen{$b} :exists) || (%in_after{$b} :exists);

        %seen<$b> = 1;

        @diff.push('-', $b);
    }

    #%seen = ();

    for @after -> $a {
        next if (%seen{$a} :exists) || (%in_before{$a} :exists);

        %seen<$a> = 1;

        @diff.push('+', $a);
    }

    return @diff;
}

# vim: ft=perl6

