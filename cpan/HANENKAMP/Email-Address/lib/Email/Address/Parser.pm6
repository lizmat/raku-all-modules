use v6;
unit package Email::Address;

# no precompilation;
# use Grammar::Tracer;

grammar RFC5234-Parser {
    # ALPHA          =  %x41-5A / %x61-7A   ; A-Z / a-z
    token alpha      { <[ \x[41]..\x[5a] \x[61]..\x[7a] ]> }

    # DIGIT          =  %x30-39
    #                        ; 0-9
    token digit      { <[ \x[30]..\x[39] ]> }

	# CR             =  %x0D\r
	#                        ; carriage return\r
	token cr         { \x[0d] }

	# LF             =  %x0A\r
	#                        ; linefeed\r
	token lf         { \x[0a] }

	# CRLF           =  CR LF\r
	#                        ; Internet standard newline\r
	token crlf       { <cr> <lf> }

	# DQUOTE         =  %x22\r
	# 					; " (Double Quote)\r
	token dquote     { \x[22] }

	# HTAB           =  %x09\r
	#                   ; horizontal tab\r
	token htab       { \x[09] }

	# SP             =  %x20\r
	token sp         { \x[20] }

    # WSP            =  SP / HTAB\r
    #                        ; white space\r
	token wsp        { <sp> || <htab> }

    # VCHAR          =  %x21-7E
    #                        ; visible (printing) characters
    token vchar      { <[ \x[21]..\x[7e] ]> }
}

grammar RFC5322-Parser is RFC5234-Parser {
    token TOP         { <address-list> }

    # address         =   mailbox / group\r
	token address     { <mailbox> | <group> }

    # mailbox         =   name-addr / addr-spec\r
	token mailbox     { <name-addr> | <addr-spec> }

    # name-addr       =   [display-name] angle-addr\r
    token name-addr   { <display-name>? <angle-addr> }

    # angle-addr      =   [CFWS] "<" addr-spec ">" [CFWS] /\r
    #                     obs-angle-addr\r
    token angle-addr  { <.cfws>? '<' <addr-spec> '>' <.cfws>? |
                        <obs-angle-addr> }

    # group           =   display-name ":" [group-list] ";" [CFWS]\r
    token group       { <display-name> ':' <group-list>? ';' }

    # display-name    =   phrase\r
    token display-name { <phrase> }

    # mailbox-list    =   (mailbox *("," mailbox)) / obs-mbox-list\r
    token mailbox-list { [ <mailbox>+ % ',' ] | <obs-mbox-list> }

    # address-list    =   (address *("," address)) / obs-addr-list\r
    token address-list { [ <address>+ % ',' ] | <obs-addr-list> }

    # group-list      =   mailbox-list / CFWS / obs-group-list\r
    token group-list  { <mailbox-list> | <cfws> | <obs-group-list> }

    # addr-spec       =   local-part "@" domain\r
    token addr-spec   { <local-part> '@' <domain> }

    # local-part      =   dot-atom / quoted-string / obs-local-part\r
    token local-part  { <dot-atom> | <quoted-string> | <obs-local-part> }

    # domain          =   dot-atom / domain-literal / obs-domain\r
    token domain      { <dot-atom> | <domain-literal> | <obs-domain> }

    # domain-literal  =   [CFWS] "[" *([FWS] dtext) [FWS] "]" [CFWS]\r
    token domain-literal { $<pre-literal> = [ <cfws>? ] '[' $<literal> = [ [ <fws>? <dtext> ]* <fws> ] ']' }

    # dtext           =   %d33-90 /          ; Printable US-ASCII\r
    #                     %d94-126 /         ;  characters not including\r
    #                     obs-dtext          ;  "[", "]", or "\\"\r
    token dtext       { <[ \x[21]..\x[5a] ]> |
                        <[ \x[5e]..\x[7e] ]> |
                        <obs-dtext> }

    # word            =   atom / quoted-string\r
    token word        { <atom> | <quoted-string> }

    # phrase          =   1*word / obs-phrase\r
    token phrase      { <word>+ | <obs-phrase> }

    # atext           =   ALPHA / DIGIT /    ; Printable US-ASCII\r
    #                     "!" / "#" /        ;  characters not including\r
    #                     "\$" / "%" /        ;  specials.  Used for atoms.\r
    #                     "&" / "'" /\r
    #                     "*" / "+" /\r
    #                     "-" / "/" /\r
    #                     "=" / "?" /\r
    #                     "^" / "_" /\r
    #                     "`" / "{" /\r
    #                     "|" / "}" /\r
    #                     "~"\r
    token atext       { <alpha> | <digit> |
                        '!' | '#' |
                        '\$' | '%' |
                        '&' | "'" |
                        '*' | '+' |
                        '-' | '/' |
                        '=' | '?' |
                        '^' | '_' |
                        '`' | '{' |
                        '|' | '}' |
                        '~' }

    # atom            =   [CFWS] 1*atext [CFWS]\r
    token atom        { $<pre> = [ <cfws>? ] <atext>+ $<post> = [ <cfws>? ] }

    # dot-atom-text   =   1*atext *("." 1*atext)\r
    token dot-atom-text { $<atexts> = [ <atext>+ ]+ % '.' }

    # dot-atom        =   [CFWS] dot-atom-text [CFWS]\r
    token dot-atom    { $<pre> = [ <cfws>? ] <dot-atom-text> $<post> = [ <cfws>? ] }

    # FWS             =   ([*WSP CRLF] 1*WSP) /  obs-FWS\r
    #                                        ; Folding white space\r
    token fws         { [ [ <wsp>* <crlf> ]? <wsp>+ ] | <obs-fws> }

    # ctext           =   %d33-39 /          ; Printable US-ASCII\r
    #                     %d42-91 /          ;  characters not including\r
    #                     %d93-126 /         ;  "(", ")", or "\"\r
    #                     obs-ctext\r
    token ctext       { <[ \x[21]..\x[27]
                           \x[2a]..\x[5b]
                           \x[5d]..\x[7e] ]> |
                        <obs-ctext> }

    # ccontent        =   ctext / quoted-pair / comment\r
    token ccontent    { <ctext> | <quoted-pair> | <comment> }

    # comment         =   "(" *([FWS] ccontent) [FWS] ")"\r
    token comment     { '(' $<comment-content> = [ [ <fws>? <ccontent> ]* <fws>? ] ')' }

    # CFWS            =   (1*([FWS] comment) [FWS]) / FWS\r
    token cfws        { [ [ $<pres> = [ <fws>? ] <comment> ]+ $<post> = [ <fws>? ] ] | $<orelse> = <fws> }

    # obs-FWS         =   1*WSP *(CRLF 1*WSP)\r
    token obs-fws     { <wsp>+ [ <crlf> <wsp>+ ]* }

    # qtext           =   %d33 /             ; Printable US-ASCII\r
    #                     %d35-91 /          ;  characters not including\r
    #                     %d93-126 /         ;  "\" or the quote character\r
    #                     obs-qtext\r
    token qtext       { <[ \x[21]
                           \x[23]..\x[5b]
                           \x[5d]..\x[7e] ]> |
                        <obs-qtext> }

    # qcontent        =   qtext / quoted-pair\r
    token qcontent    { <qtext> | <quoted-pair> }

    # quoted-string   =   [CFWS]\r
    #                     DQUOTE *([FWS] qcontent) [FWS] DQUOTE\r
    #                     [CFWS]\r
    token quoted-string { <.cfws>?
                          <.dquote> $<quoted-string> = [ [ <.fws>? <qcontent> ]* <.fws>? ] <.dquote>
                          <.cfws>? }

    # obs-NO-WS-CTL   =   %d1-8 /            ; US-ASCII control\r
    #                     %d11 /             ;  characters that do not\r
    #                     %d12 /             ;  include the carriage\r
    #                     %d14-31 /          ;  return, line feed, and\r
    #                     %d127              ;  white space characters\r
    token obs-no-ws-ctl { <[ \x1..\x8
                             \xb
                             \xc
                             \xe..\x[1f]
                             \x[7f] ]> }

    # obs-ctext       =   obs-NO-WS-CTL\r
    token obs-ctext   { <obs-no-ws-ctl> }

    # obs-qtext       =   obs-NO-WS-CTL\r
    token obs-qtext   { <obs-no-ws-ctl> }

    # obs-qp          =   "\\" (%d0 / obs-NO-WS-CTL / LF / CR)\r
    token obs-qp      { '\\' [ \0 | <obs-no-ws-ctl> | <lf> | <cr> ] }

    # obs-phrase      =   word *(word / "." / CFWS)\r
    token obs-phrase  { $<head> = <word> $<tail> = [ <word> | '.' | <cfws> ]* }

    # quoted-pair     =   ("\\" (VCHAR / WSP)) / obs-qp\r
    token quoted-pair { [ '\\' [ <vchar> | <wsp> ] ] | <obs-qp> }

    # obs-angle-addr  =   [CFWS] "<" obs-route addr-spec ">" [CFWS]
    token obs-angle-addr { <cfws>? '<' <obs-route> <addr-spec> '>' <cfws>? }

    # obs-route       =   obs-domain-list ":"
    token obs-route   { <obs-domain-list> ':' }

    # obs-domain-list =   *(CFWS / ",") "@" domain
    #                     *("," [CFWS] ["@" domain])
    token obs-domain-list { [ <.cfws> | ',' ]* '@' $<head> = <domain>
                            $<tail> = [ ',' <.cfws>? [ '@' <domain> ]? ]* }

    # obs-mbox-list   =   *([CFWS] ",") mailbox *("," [mailbox / CFWS])
    token obs-mbox-list { [ <cfws>? ',' ]* $<head> = <mailbox> $<tail> = [ ',' [ <mailbox> | <cfws> ]? ]* }

    # obs-addr-list   =   *([CFWS] ",") address *("," [address / CFWS])
    token obs-addr-list { [ <cfws>? ',' ]* <address> [ ',' [ <address> | <cfws> ]? ]* }

    # obs-group-list  =   1*([CFWS] ",") [CFWS]
    token obs-group-list { [ <cfws>? ',' ]+ <cfws>? }

    # obs-local-part  =   word *("." word)
    token obs-local-part { <word>+ % '.' }

    # obs-domain      =   atom *("." atom)
    token obs-domain  { <atom>+ % '.' }

    # obs-dtext       =   obs-NO-WS-CTL / quoted-pair
    token obs-dtext   { <obs-no-ws-ctl> | <quoted-pair> }
}

class RFC5322-Actions {
    sub unfold-fws($_) { S:global/ "\r\n" ( " " | "\t" ) /$0/ }
    sub unquote-pairs($_) { S:global/ "\\" ( " " | "\t" | "\0" | <[ \x1..\x8 \xb \xc \xe..\x[1f] \x[7f] ]> | "\n" | "\r" ) /$0/ }

    method TOP($/) { make $<address-list>.made }
    method address($/) { make $<mailbox>.made // $<group>.made }
    method mailbox($/) { make $<name-addr>.made // $<addr-spec>.made }
    method name-addr($/) {
        make %(
            type         => 'mailbox',
            display-name => $<display-name>.made,
            address      => $<angle-addr>.made,
            comment      => $*comments.drain,
            original     => ~$/,
        )
    }
    method angle-addr($/) { make $<addr-spec>.made // $<obs-angle-addr>.made }
    method group($/) {
        make %(
            type         => 'group',
            display-name => $<display-name>.made,
            mailbox-list => $<group-list>.made,
            original     => ~$/,
        )
    }
    method display-name($/) { make $<phrase>.made }
    method mailbox-list($/) { make $<mailbox>».made // $<obs-mbox-list>.made }
    method address-list($/) { make $<address>».made // $<obs-addr-list>.made }
    method group-list($/) { make $<mailbox-list>.made // $<obs-group-list>.made // [] }
    method addr-spec($/) {
        make %(
            local-part => $<local-part>.made,
            domain     => $<domain>.made,
            original   => ~$/,
        )
    }
    method local-part($/) { make $<dot-atom>.made // $<quoted-string>.made // $<obs-local-part>.made }
    method domain($/) { make $<dot-atom>.made // $<domain-literal>.made // $<obs-domain>.made }
    method domain-literal($/) {
        make ($<pre-literal>.made ~ "[$<literal>]").&unfold-fws.&unquote-pairs
    }
    method word($/) { make $<atom>.made // $<quoted-string>.made }
    method phrase($/) { make [~] @($<word>».made) // $<obs-phrase>.made }
    method atom($/) { quietly make $<pre>.made ~ ([~] $<atext>) ~ $<post>.made }
    method dot-atom-text($/) { make [~] $<atexts> }
    method dot-atom($/) { quietly make $<pre>.made ~ $<dot-atom-text>.made ~ $<post>.made }
    method quoted-string($/) { make "$<quoted-string>".&unquote-pairs }
    method comment($/) { $*comments.append("$<comment-content>".&unquote-pairs) }
    method cfws($/) { quietly make [~] |$<pres>, $<post> }
    method obs-phrase($/) {
        make $<head>.made ~ $<tail>.map({
            when '.' { '.' }
            default { .made }
        });
    }
    method obs-angle-addr($/) {
        my %address = $<addr-spec>.made;
        %address<local-part> = $<obs-route>.made ~ %address<local-poart>;
        make %address;
    }
    method obs-route($/) { make $<obs-domain-list>.made ~ ':' }
    method obs-domain-list($/) {
        make join ',', ($<head>.made, |$<tail>.map({ $<domain>.made }));
    }
    method obs-mbox-list($/) {
        make ($<head>.made, |$<tail>».made);
    }
}

module Parser {
    our sub parse-email-address($str, :$parser, :$actions, :$rule) is export(:parse-email-address) {
        my $*comments = class {
            has $.comment;
            method drain() { my $c = $!comment; $!comment = Nil; $c }
            method append($c) {
                with $!comment { $!comment ~= $c }
                else { $!comment = $c }
            }
        }.new;

        $parser.parse($str, :$actions, :$rule).made;
    }
}

=begin pod

=head1 NAME

Email::Address::Parser - parser internals

=head1 DESCRIPTION

This compunit contains the parser classes. These are directly translated from the ABNF in RFC 5322 and related RFCs.

Use of these components directly is undocumented. Direct use of these APIs should be avoided.

=head1 MODULES

=head2 Email::Address::RFC5322-Parser

This is a Perl 6 grammar translated directly from the RFC 5233 ABNF grammar.

=head3 method parse

    method parse(Str $str, :$actions, :$rule);

Parses a string and returns information about an email address list.

=head2 Email::Address::RFC5322-Actions

This is an actions that can be paired with the grammar that turns the parsed matches into hashes and lists of hashes that are easier to work with.

=head2 Email::Address::Parser

Contains magicky magic stuff that does magic with butterflies.

=end pod
