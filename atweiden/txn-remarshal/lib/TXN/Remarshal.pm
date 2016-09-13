use v6;
use TXN::Parser;
use TXN::Parser::Types;
unit module TXN::Remarshal;

# remarshal {{{

# --- format {{{

subset Format of Str where /ENTRY|HASH|JSON|TXN/;
multi sub gen-format('entry') returns Format { 'ENTRY' }
multi sub gen-format('hash') returns Format { 'HASH' }
multi sub gen-format('json') returns Format { 'JSON' }
multi sub gen-format('txn') returns Format { 'TXN' }

# --- end format }}}

multi sub remarshal(
    $input,
    Str :if(:$input-format),
    Str :of(:$output-format)
) is export
{
    my Format $if = gen-format($input-format);
    my Format $of = gen-format($output-format);
    remarshal($input, $if, $of);
}

# ------------------------------------------------------------------------------
# --- no conversion required {{{

multi sub remarshal($input, 'ENTRY', 'ENTRY') { $input }
multi sub remarshal($input, 'HASH', 'HASH') { $input }
multi sub remarshal($input, 'JSON', 'JSON') { $input }
multi sub remarshal($input, 'TXN', 'TXN') { $input }

# --- end no conversion required }}}
# ------------------------------------------------------------------------------
# --- txn ↔ entry {{{

multi sub remarshal(Str $txn, 'TXN', 'ENTRY') returns Array
{
    my TXN::Parser::AST::Entry @entry = from-txn($txn);
}

multi sub remarshal(TXN::Parser::AST::Entry @entry, 'ENTRY', 'TXN') returns Str
{
    my Str $txn = to-txn(@entry);
}

multi sub remarshal(TXN::Parser::AST::Entry $entry, 'ENTRY', 'TXN') returns Str
{
    my Str $txn = to-txn($entry);
}

# --- end txn ↔ entry }}}
# --- entry ↔ hash {{{

multi sub remarshal(
    TXN::Parser::AST::Entry @entry,
    'ENTRY',
    'HASH'
) returns Array
{
    my @e = to-hash(@entry);
}

multi sub remarshal(
    TXN::Parser::AST::Entry $entry,
    'ENTRY',
    'HASH'
) returns Hash
{
    my %e = to-hash($entry);
}

multi sub remarshal(@e, 'HASH', 'ENTRY') returns Array
{
    my TXN::Parser::AST::Entry @entry = from-hash(:entry(@e));
}

multi sub remarshal(%e, 'HASH', 'ENTRY') returns TXN::Parser::AST::Entry
{
    my TXN::Parser::AST::Entry $entry = from-hash(:entry(%e));
}

# --- end entry ↔ hash }}}
# --- hash ↔ json {{{

multi sub remarshal(@e, 'HASH', 'JSON') returns Str
{
    my Str $json = to-json(@e);
}

multi sub remarshal(%e, 'HASH', 'JSON') returns Str
{
    my Str $json = to-json(%e);
}

multi sub remarshal(Str $json, 'JSON', 'HASH') returns Array
{
    my @e = from-json($json);
}

# --- end hash ↔ json }}}
# ------------------------------------------------------------------------------
# --- txn ↔ hash {{{

multi sub remarshal(Str $txn, 'TXN', 'HASH') returns Array
{
    my TXN::Parser::AST::Entry @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
}

multi sub remarshal(@e, 'HASH', 'TXN') returns Str
{
    my TXN::Parser::AST::Entry @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ hash }}}
# --- txn ↔ json {{{

multi sub remarshal(Str $txn, 'TXN', 'JSON') returns Str
{
    my TXN::Parser::AST::Entry @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(Str $json, 'JSON', 'TXN') returns Str
{
    my @e = remarshal($json, 'JSON', 'HASH');
    my TXN::Parser::AST::Entry @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ json }}}
# ------------------------------------------------------------------------------
# --- entry ↔ json {{{

multi sub remarshal(TXN::Parser::AST::Entry @entry, 'ENTRY', 'JSON') returns Str
{
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(TXN::Parser::AST::Entry $entry, 'ENTRY', 'JSON') returns Str
{
    my %e = remarshal($entry, 'ENTRY', 'HASH');
    my Str $json = remarshal(%e, 'HASH', 'JSON');
}

# --- end entry ↔ json }}}
# ------------------------------------------------------------------------------

# end remarshal }}}

# txn ↔ entry
# sub from-txn {{{

multi sub from-txn(
    Str $content,
    *%opts (
        Str :$txn-dir,
        Int :$date-local-offset
    )
) is export returns Array
{
    my TXN::Parser::AST::Entry @entry =
        TXN::Parser.parse($content, |%opts).made;
}

multi sub from-txn(
    Str :$file!,
    *%opts (
        Str :$txn-dir,
        Int :$date-local-offset
    )
) is export returns Array
{
    my TXN::Parser::AST::Entry @entry =
        TXN::Parser.parsefile($file, |%opts).made;
}

# end sub from-txn }}}
# sub to-txn {{{

# --- Entry {{{

multi sub to-txn(TXN::Parser::AST::Entry @entry) is export returns Str
{
    @entry.map({ to-txn($_) }).join("\n" x 2);
}

multi sub to-txn(TXN::Parser::AST::Entry $entry) is export returns Str
{
    my TXN::Parser::AST::Entry::Header $header = $entry.header;
    my TXN::Parser::AST::Entry::Posting @posting = $entry.posting;
    my Str $s = join("\n", to-txn($header), to-txn(@posting));
    $s;
}

# --- end Entry }}}
# --- Entry::Header {{{

multi sub to-txn(TXN::Parser::AST::Entry::Header $header) returns Str
{
    my Dateish $date = $header.date;
    my Str $description = $header.description if $header.description;
    my UInt $important = $header.important;
    my VarName @tag = $header.tag if $header.tag;

    my Str $s = ~$date;
    $s ~= "\n" ~ @tag.map({ '#' ~ $_ }).join(' ') if @tag;
    $s ~= ' ' ~ '!' x $important if $important > 0;

    if $description
    {
        my Str $d = qq:to/EOF/;
        '''
        $description
        '''
        EOF
        $s ~= "\n" ~ $d.trim;
    }

    $s.trim;
}

# --- end Entry::Header }}}
# --- Entry::Posting {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting @posting) returns Str
{
    @posting.map({ to-txn($_) }).join("\n");
}

multi sub to-txn(TXN::Parser::AST::Entry::Posting $posting) returns Str
{
    my TXN::Parser::AST::Entry::Posting::Account $account = $posting.account;
    my TXN::Parser::AST::Entry::Posting::Amount $amount = $posting.amount;
    my DecInc $decinc = $posting.decinc;
    my TXN::Parser::AST::Entry::Posting::Annot $annot = $posting.annot
        if $posting.annot;

    my Bool $needs-minus = so $decinc ~~ DEC;

    # check if $amount includes C<:plus-or-minus('-')>
    # if so, we don't need to negate the posting amount
    my Bool $has-minus = $amount.plus-or-minus
        ?? $amount.plus-or-minus eq '-'
        !! False;

    my Str $s = to-txn($account) ~ ' ' x 4;
    if $needs-minus
    {
        unless $has-minus
        {
            $s ~= '-';
        }
    }

    $s ~= to-txn($amount);
    $s ~= ' ' ~ to-txn($annot) if $annot;
    $s;
}

# --- end Entry::Posting }}}
# --- Entry::Posting::Account {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Account $account) returns Str
{
    my Silo $silo = $account.silo;
    my VarName $entity = $account.entity;
    my VarName @path = $account.path if $account.path;

    my Str $s = $silo.gist.tclc ~ ':' ~ $entity;
    $s ~= ':' ~ @path.join(':') if @path;
    $s;
}

# --- end Entry::Posting::Account }}}
# --- Entry::Posting::Amount {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Amount $amount) returns Str
{
    my AssetCode $asset-code = $amount.asset-code;
    my Quantity $asset-quantity = $amount.asset-quantity;
    my AssetSymbol $asset-symbol = $amount.asset-symbol if $amount.asset-symbol;
    my PlusMinus $plus-or-minus = $amount.plus-or-minus if $amount.plus-or-minus;

    my Str $s = '';
    $s ~= $plus-or-minus if $plus-or-minus;
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Annot $annot) returns Str
{
    my TXN::Parser::AST::Entry::Posting::Annot::Inherit $inherit =
        $annot.inherit if $annot.inherit;
    my TXN::Parser::AST::Entry::Posting::Annot::Lot $lot =
        $annot.lot if $annot.lot;
    my TXN::Parser::AST::Entry::Posting::Annot::XE $xe =
        $annot.xe if $annot.xe;

    my Str @a;
    push @a, to-txn($xe) if $xe;
    push @a, to-txn($inherit) if $inherit;
    push @a, to-txn($lot) if $lot;

    my Str $s = '';
    $s ~= join(' ', @a);
    $s;
}

# --- end Entry::Posting::Annot }}}
# --- Entry::Posting::Annot::Inherit {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Annot::Inherit $inherit) returns Str
{
    my AssetCode $asset-code = $inherit.asset-code;
    my Quantity $asset-quantity = $inherit.asset-quantity;
    my AssetSymbol $asset-symbol = $inherit.asset-symbol if $inherit.asset-symbol;

    my Str $s = '« ';
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- end Entry::Posting::Annot::Inherit }}}
# --- Entry::Posting::Annot::Lot {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Annot::Lot $lot) returns Str
{
    my VarName $name = $lot.name;
    my DecInc $decinc = $lot.decinc;

    my Str $s = do given $decinc
    {
        when DEC
        {
            '←';
        }
        when INC
        {
            '→';
        }
    }
    $s ~= ' [' ~ $name ~ ']';
    $s;
}

# --- end Entry::Posting::Annot::Lot }}}
# --- Entry::Posting::Annot::XE {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Annot::XE $xe) returns Str
{
    my AssetCode $asset-code = $xe.asset-code;
    my Quantity $asset-quantity = $xe.asset-quantity;
    my AssetSymbol $asset-symbol = $xe.asset-symbol if $xe.asset-symbol;

    my Str $s = '@ ';
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- end Entry::Posting::Annot::XE }}}

# end sub to-txn }}}

# entry ↔ hash
# sub from-hash {{{

# --- Entry {{{

multi sub from-hash(:@entry!) returns Array
{
    my TXN::Parser::AST::Entry @e = @entry.map({ from-hash(:entry($_)) });
}

multi sub from-hash(
    :%entry! (
        :%header!,
        :%id!,
        :@posting!
    )
) returns TXN::Parser::AST::Entry
{
    my %e;

    my TXN::Parser::AST::Entry::Header $header = from-hash(:%header);
    my TXN::Parser::AST::Entry::ID $id = from-hash(:entry-id(%id));
    my TXN::Parser::AST::Entry::Posting @p = from-hash(:@posting);

    %e<header> = $header;
    %e<id> = $id;
    %e<posting> = @p;

    TXN::Parser::AST::Entry.new(|%e);
}

# --- end Entry }}}
# --- Entry::Header {{{

multi sub from-hash(
    :%header! (
        :$date!,
        :$description,
        :$important,
        :@tag
    )
) returns TXN::Parser::AST::Entry::Header
{
    my %h;

    my TXN::Parser::Actions $actions .= new;
    my Dateish $d =
        TXN::Parser::Grammar.parse($date, :rule<date>, :$actions).made;
    my Str $s = $description if $description;
    my UInt $i = $important if $important;
    my Str @t = @tag if @tag;

    %h<date> = $d;
    %h<description> = $s if $s;
    %h<important> = $i if $i;

    TXN::Parser::AST::Entry::Header.new(|%h, :tag(@t));
}

# --- end Entry::Header }}}
# --- Entry::ID {{{

multi sub from-hash(
    :%entry-id! (
        :@number!,
        :$text!,
        :$xxhash!
    )
) returns TXN::Parser::AST::Entry::ID
{
    my %e;

    my UInt @n = @number;
    my Str $t = $text;
    my XXHash $x = $xxhash;

    %e<text> = $t;
    %e<xxhash> = $x;

    # XXX text → xxhash not checked
    TXN::Parser::AST::Entry::ID.new(|%e, :number(@n));
}

# --- end Entry::ID }}}
# --- Entry::Posting {{{

multi sub from-hash(:@posting!) returns Array
{
    my TXN::Parser::AST::Entry::Posting @p =
        @posting.map({ from-hash(:posting($_)) });
}

multi sub from-hash(:%posting!) returns TXN::Parser::AST::Entry::Posting
{
    my %p;

    my TXN::Parser::AST::Entry::Posting::Account $account =
        from-hash(:account(%posting<account>));
    my TXN::Parser::AST::Entry::Posting::Amount $amount =
        from-hash(:amount(%posting<amount>));
    my TXN::Parser::AST::Entry::Posting::Annot $annot =
        from-hash(:annot(%posting<annot>)) if %posting<annot>;
    my TXN::Parser::AST::Entry::Posting::ID $id =
        from-hash(:posting-id(%posting<id>));

    my DecInc $d = ::(%posting<decinc>);

    %p<account> = $account;
    %p<amount> = $amount;
    %p<annot> = $annot if $annot;
    %p<id> = $id;
    %p<decinc> = $d;

    TXN::Parser::AST::Entry::Posting.new(|%p);
}

# --- end Entry::Posting }}}
# --- Entry::Posting::Account {{{

multi sub from-hash(
    :%account! (
        :$silo!,
        :$entity!,
        :@path
    )
) returns TXN::Parser::AST::Entry::Posting::Account
{
    my %a;

    my Silo $s = ::($silo);
    my Str $e = $entity;
    my Str @p = @path if @path;

    %a<silo> = $s;
    %a<entity> = $e;

    TXN::Parser::AST::Entry::Posting::Account.new(|%a, :path(@p));
}

# --- end Entry::Posting::Account }}}
# --- Entry::Posting::Amount {{{

multi sub from-hash(
    :%amount! (
        :$asset-code!,
        :$asset-quantity!,
        :$asset-symbol,
        :$plus-or-minus
    )
) returns TXN::Parser::AST::Entry::Posting::Amount
{
    my %a;

    my Str $c = $asset-code;
    my Quantity $q = FatRat($asset-quantity);
    my Str $s = $asset-symbol if $asset-symbol;
    my Str $p = $plus-or-minus if $plus-or-minus;

    %a<asset-code> = $c;
    %a<asset-quantity> = $q;
    %a<asset-symbol> = $s if $s;
    %a<plus-or-minus> = $p if $p;

    TXN::Parser::AST::Entry::Posting::Amount.new(|%a);
}

# --- end Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub from-hash(:%annot!) returns TXN::Parser::AST::Entry::Posting::Annot
{
    my %a;

    my TXN::Parser::AST::Entry::Posting::Annot::Inherit $inherit =
        from-hash(:inherit(%annot<inherit>)) if %annot<inherit>;
    my TXN::Parser::AST::Entry::Posting::Annot::Lot $lot =
        from-hash(:lot(%annot<lot>)) if %annot<lot>;
    my TXN::Parser::AST::Entry::Posting::Annot::XE $xe =
        from-hash(:xe(%annot<xe>)) if %annot<xe>;

    %a<inherit> = $inherit if $inherit;
    %a<lot> = $lot if $lot;
    %a<xe> = $xe if $xe;

    TXN::Parser::AST::Entry::Posting::Annot.new(|%a);
}

# --- end Entry::Posting::Annot }}}
# --- Entry::Posting::Annot::Inherit {{{

multi sub from-hash(
    :%inherit! (
        :$asset-code!,
        :$asset-quantity!,
        :$asset-symbol
    )
) returns TXN::Parser::AST::Entry::Posting::Annot::Inherit
{
    my %i;

    my Str $c = $asset-code;
    my Quantity $q = FatRat($asset-quantity);
    my Str $s = $asset-symbol if $asset-symbol;

    %i<asset-code> = $c;
    %i<asset-quantity> = $q;
    %i<asset-symbol> = $s if $s;

    TXN::Parser::AST::Entry::Posting::Annot::Inherit.new(|%i);
}

# --- end Entry::Posting::Annot::Inherit }}}
# --- Entry::Posting::Annot::Lot {{{

multi sub from-hash(
    :%lot! (
        :$decinc!,
        :$name!
    )
) returns TXN::Parser::AST::Entry::Posting::Annot::Lot
{
    my %l;

    my DecInc $d = ::($decinc);
    my Str $n = $name;

    %l<decinc> = $d;
    %l<name> = $n;

    TXN::Parser::AST::Entry::Posting::Annot::Lot.new(|%l);
}

# --- end Entry::Posting::Annot::Lot }}}
# --- Entry::Posting::Annot::XE {{{

multi sub from-hash(
    :%xe! (
        :$asset-code!,
        :$asset-quantity!,
        :$asset-symbol
    )
) returns TXN::Parser::AST::Entry::Posting::Annot::XE
{
    my %x;

    my Str $c = $asset-code;
    my Quantity $q = FatRat($asset-quantity);
    my Str $s = $asset-symbol if $asset-symbol;

    %x<asset-code> = $c;
    %x<asset-quantity> = $q;
    %x<asset-symbol> = $s if $s;

    TXN::Parser::AST::Entry::Posting::Annot::XE.new(|%x);
}

# --- end Entry::Posting::Annot::XE }}}
# --- Entry::Posting::ID {{{

multi sub from-hash(
    :%posting-id! (
        :%entry-id!,
        :$number!,
        :$text!,
        :$xxhash!
    )
) returns TXN::Parser::AST::Entry::Posting::ID
{
    my %p;

    # XXX text → xxhash not checked
    my TXN::Parser::AST::Entry::ID $e = from-hash(:%entry-id);
    my UInt $n = $number;
    my Str $t = $text;
    my XXHash $x = $xxhash;

    %p<entry-id> = $e;
    %p<number> = $n;
    %p<text> = $t;
    %p<xxhash> = $x;

    TXN::Parser::AST::Entry::Posting::ID.new(|%p);
}

# --- end Entry::Posting::ID }}}

# end sub from-hash }}}
# sub to-hash {{{

# --- Entry {{{

multi sub to-hash(TXN::Parser::AST::Entry @entry) returns Array
{
    my @a = @entry.map({ to-hash($_) });
}

multi sub to-hash(TXN::Parser::AST::Entry $entry) returns Hash
{
    $entry.hash;
}

# --- end Entry }}}

# end sub to-hash }}}

# hash ↔ json
# sub from-json {{{

sub from-json(Str $json) returns Array
{
    Rakudo::Internals::JSON.from-json($json).Array;
}

# end sub from-json }}}
# sub to-json {{{

multi sub to-json(@entry) returns Str
{
    Rakudo::Internals::JSON.to-json(@entry);
}

multi sub to-json(%entry) returns Str
{
    Rakudo::Internals::JSON.to-json(%entry);
}

# end sub to-json }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
