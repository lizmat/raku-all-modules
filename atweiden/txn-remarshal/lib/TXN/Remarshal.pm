use v6;
use TXN::Parser;
use TXN::Parser::Types;
unit module TXN::Remarshal;

# remarshal {{{

# --- format {{{

subset Format of Str where /ENTRY|HASH|JSON|TXN/;
multi sub gen-format('entry' --> Format:D) { 'ENTRY' }
multi sub gen-format('hash'  --> Format:D) { 'HASH' }
multi sub gen-format('json'  --> Format:D) { 'JSON' }
multi sub gen-format('txn'   --> Format:D) { 'TXN' }

# --- end format }}}

multi sub remarshal(
    $input,
    Str:D :if(:$input-format) where /entry|hash|json|txn/,
    Str:D :of(:$output-format) where /entry|hash|json|txn/
) is export
{
    my Format:D $if = gen-format($input-format);
    my Format:D $of = gen-format($output-format);
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

multi sub remarshal(Str:D $txn, 'TXN', 'ENTRY' --> Array:D)
{
    my TXN::Parser::AST::Entry:D @entry = from-txn($txn);
}

multi sub remarshal(
    TXN::Parser::AST::Entry:D @entry,
    'ENTRY',
    'TXN'
    --> Str:D
)
{
    my Str:D $txn = to-txn(@entry);
}

multi sub remarshal(
    TXN::Parser::AST::Entry:D $entry,
    'ENTRY',
    'TXN'
    --> Str:D
)
{
    my Str:D $txn = to-txn($entry);
}

# --- end txn ↔ entry }}}
# --- entry ↔ hash {{{

multi sub remarshal(
    TXN::Parser::AST::Entry:D @entry,
    'ENTRY',
    'HASH'
    --> Array:D
)
{
    my @e = to-hash(@entry);
}

multi sub remarshal(
    TXN::Parser::AST::Entry:D $entry,
    'ENTRY',
    'HASH'
    --> Hash:D
)
{
    my %e = to-hash($entry);
}

multi sub remarshal(@e, 'HASH', 'ENTRY' --> Array:D)
{
    my TXN::Parser::AST::Entry:D @entry = from-hash(:entry(@e));
}

multi sub remarshal(%e, 'HASH', 'ENTRY' --> TXN::Parser::AST::Entry:D)
{
    my TXN::Parser::AST::Entry:D $entry = from-hash(:entry(%e));
}

# --- end entry ↔ hash }}}
# --- hash ↔ json {{{

multi sub remarshal(@e, 'HASH', 'JSON' --> Str:D)
{
    my Str:D $json = to-json(@e);
}

multi sub remarshal(%e, 'HASH', 'JSON' --> Str:D)
{
    my Str:D $json = to-json(%e);
}

multi sub remarshal(Str:D $json, 'JSON', 'HASH' --> Array:D)
{
    my @e = from-json($json);
}

# --- end hash ↔ json }}}
# ------------------------------------------------------------------------------
# --- txn ↔ hash {{{

multi sub remarshal(Str:D $txn, 'TXN', 'HASH' --> Array:D)
{
    my TXN::Parser::AST::Entry:D @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
}

multi sub remarshal(@e, 'HASH', 'TXN' --> Str:D)
{
    my TXN::Parser::AST::Entry:D @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str:D $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ hash }}}
# --- txn ↔ json {{{

multi sub remarshal(Str:D $txn, 'TXN', 'JSON' --> Str:D)
{
    my TXN::Parser::AST::Entry:D @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str:D $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(Str:D $json, 'JSON', 'TXN' --> Str:D)
{
    my @e = remarshal($json, 'JSON', 'HASH');
    my TXN::Parser::AST::Entry:D @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str:D $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ json }}}
# ------------------------------------------------------------------------------
# --- entry ↔ json {{{

multi sub remarshal(
    TXN::Parser::AST::Entry:D @entry,
    'ENTRY',
    'JSON'
    --> Str:D
)
{
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str:D $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(
    TXN::Parser::AST::Entry:D $entry,
    'ENTRY',
    'JSON'
    --> Str:D
)
{
    my %e = remarshal($entry, 'ENTRY', 'HASH');
    my Str:D $json = remarshal(%e, 'HASH', 'JSON');
}

# --- end entry ↔ json }}}
# ------------------------------------------------------------------------------

# end remarshal }}}

# txn ↔ entry
# sub from-txn {{{

multi sub from-txn(
    Str:D $content,
    *%opts (
        Str :txn-dir($),
        Int :date-local-offset($)
    )
    --> Array:D
) is export
{
    my TXN::Parser::AST::Entry:D @entry =
        TXN::Parser.parse($content, |%opts).made;
}

multi sub from-txn(
    Str:D :$file! where *.so,
    *%opts (
        Str :txn-dir($),
        Int :date-local-offset($)
    )
    --> Array:D
) is export
{
    my TXN::Parser::AST::Entry:D @entry =
        TXN::Parser.parsefile($file, |%opts).made;
}

# end sub from-txn }}}
# sub to-txn {{{

# --- Entry {{{

multi sub to-txn(TXN::Parser::AST::Entry:D @entry --> Str:D) is export
{
    @entry.map({ to-txn($_) }).join("\n" x 2);
}

multi sub to-txn(TXN::Parser::AST::Entry:D $entry --> Str:D) is export
{
    my TXN::Parser::AST::Entry::Header:D $header = $entry.header;
    my TXN::Parser::AST::Entry::Posting:D @posting = $entry.posting;
    my Str:D $s = join("\n", to-txn($header), to-txn(@posting));
    $s;
}

# --- end Entry }}}
# --- Entry::Header {{{

multi sub to-txn(TXN::Parser::AST::Entry::Header:D $header --> Str:D)
{
    my Dateish:D $date = $header.date;
    my Str:D $description = $header.description if $header.description;
    my UInt:D $important = $header.important;
    my VarName:D @tag = $header.tag if $header.tag;

    my Str:D $s = ~$date;
    $s ~= "\n" ~ @tag.map({ '#' ~ $_ }).join(' ') if @tag;
    $s ~= ' ' ~ '!' x $important if $important > 0;

    if $description
    {
        my Str:D $d = qq:to/EOF/;
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

multi sub to-txn(TXN::Parser::AST::Entry::Posting:D @posting --> Str:D)
{
    @posting.map({ to-txn($_) }).join("\n");
}

multi sub to-txn(TXN::Parser::AST::Entry::Posting:D $posting --> Str:D)
{
    my TXN::Parser::AST::Entry::Posting::Account:D $account = $posting.account;
    my TXN::Parser::AST::Entry::Posting::Amount:D $amount = $posting.amount;
    my DecInc:D $decinc = $posting.decinc;
    my TXN::Parser::AST::Entry::Posting::Annot:D $annot = $posting.annot
        if $posting.annot;

    my Bool:D $needs-minus = so $decinc ~~ DEC;

    # check if $amount includes C<:plus-or-minus('-')>
    # if so, we don't need to negate the posting amount
    my Bool:D $has-minus = $amount.plus-or-minus
        ?? $amount.plus-or-minus eq '-'
        !! False;

    my Str:D $s = to-txn($account) ~ ' ' x 4;
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

multi sub to-txn(
    TXN::Parser::AST::Entry::Posting::Account:D $account
    --> Str:D
)
{
    my Silo:D $silo = $account.silo;
    my VarName:D $entity = $account.entity;
    my VarName:D @path = $account.path if $account.path;

    my Str:D $s = $silo.gist.tclc ~ ':' ~ $entity;
    $s ~= ':' ~ @path.join(':') if @path;
    $s;
}

# --- end Entry::Posting::Account }}}
# --- Entry::Posting::Amount {{{

multi sub to-txn(
    TXN::Parser::AST::Entry::Posting::Amount:D $amount
    --> Str:D
)
{
    my AssetCode:D $asset-code = $amount.asset-code;
    my Quantity:D $asset-quantity = $amount.asset-quantity;
    my AssetSymbol:D $asset-symbol = $amount.asset-symbol
        if $amount.asset-symbol;
    my PlusMinus:D $plus-or-minus = $amount.plus-or-minus
        if $amount.plus-or-minus;

    my Str:D $s = '';
    $s ~= $plus-or-minus if $plus-or-minus;
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub to-txn(TXN::Parser::AST::Entry::Posting::Annot:D $annot --> Str:D)
{
    my TXN::Parser::AST::Entry::Posting::Annot::Inherit:D $inherit =
        $annot.inherit if $annot.inherit;
    my TXN::Parser::AST::Entry::Posting::Annot::Lot:D $lot =
        $annot.lot if $annot.lot;
    my TXN::Parser::AST::Entry::Posting::Annot::XE:D $xe =
        $annot.xe if $annot.xe;

    my Str:D @a;
    push @a, to-txn($xe) if $xe;
    push @a, to-txn($inherit) if $inherit;
    push @a, to-txn($lot) if $lot;

    my Str:D $s = '';
    $s ~= join(' ', @a);
    $s;
}

# --- end Entry::Posting::Annot }}}
# --- Entry::Posting::Annot::Inherit {{{

multi sub to-txn(
    TXN::Parser::AST::Entry::Posting::Annot::Inherit:D $inherit
    --> Str:D
)
{
    my AssetCode:D $asset-code = $inherit.asset-code;
    my Price:D $asset-price = $inherit.asset-price;
    my AssetSymbol:D $asset-symbol = $inherit.asset-symbol
        if $inherit.asset-symbol;

    my Str:D $s = '« ';
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-price;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- end Entry::Posting::Annot::Inherit }}}
# --- Entry::Posting::Annot::Lot {{{

multi sub to-txn(
    TXN::Parser::AST::Entry::Posting::Annot::Lot:D $lot
    --> Str:D
)
{
    my VarName:D $name = $lot.name;
    my DecInc:D $decinc = $lot.decinc;

    my Str:D $s = do given $decinc
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

multi sub to-txn(
    TXN::Parser::AST::Entry::Posting::Annot::XE:D $xe
    --> Str:D
)
{
    my AssetCode:D $asset-code = $xe.asset-code;
    my Price:D $asset-price = $xe.asset-price;
    my AssetSymbol:D $asset-symbol = $xe.asset-symbol if $xe.asset-symbol;

    my Str:D $s = '@ ';
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-price;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- end Entry::Posting::Annot::XE }}}

# end sub to-txn }}}

# entry ↔ hash
# sub from-hash {{{

# --- Entry {{{

multi sub from-hash(:@entry! --> Array:D)
{
    my TXN::Parser::AST::Entry:D @e = @entry.map({ from-hash(:entry($_)) });
}

multi sub from-hash(
    :%entry! (
        :%header!,
        :%id!,
        :@posting!
    )
    --> TXN::Parser::AST::Entry:D
)
{
    my %e;

    my TXN::Parser::AST::Entry::Header:D $header = from-hash(:%header);
    my TXN::Parser::AST::Entry::ID:D $id = from-hash(:entry-id(%id));
    my TXN::Parser::AST::Entry::Posting:D @p = from-hash(:@posting);

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
    --> TXN::Parser::AST::Entry::Header:D
)
{
    my %h;

    my TXN::Parser::Actions:D $actions = TXN::Parser::Actions.new;
    my Dateish:D $d =
        TXN::Parser::Grammar.parse($date, :rule<date>, :$actions).made;
    my Str:D $s = $description if $description;
    my UInt:D $i = $important if $important;
    my Str:D @t = @tag if @tag;

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
    --> TXN::Parser::AST::Entry::ID:D
)
{
    my %e;

    my UInt:D @n = @number;
    my Str:D $t = $text;
    my XXHash:D $x = $xxhash;

    %e<text> = $t;
    %e<xxhash> = $x;

    # XXX text → xxhash not checked
    TXN::Parser::AST::Entry::ID.new(|%e, :number(@n));
}

# --- end Entry::ID }}}
# --- Entry::Posting {{{

multi sub from-hash(:@posting! --> Array:D)
{
    my TXN::Parser::AST::Entry::Posting:D @p =
        @posting.map({ from-hash(:posting($_)) });
}

multi sub from-hash(:%posting! --> TXN::Parser::AST::Entry::Posting:D)
{
    my %p;

    my TXN::Parser::AST::Entry::Posting::Account:D $account =
        from-hash(:account(%posting<account>));
    my TXN::Parser::AST::Entry::Posting::Amount:D $amount =
        from-hash(:amount(%posting<amount>));
    my TXN::Parser::AST::Entry::Posting::Annot:D $annot =
        from-hash(:annot(%posting<annot>)) if %posting<annot>;
    my TXN::Parser::AST::Entry::Posting::ID:D $id =
        from-hash(:posting-id(%posting<id>));

    my DecInc:D $d = ::(%posting<decinc>);

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
    --> TXN::Parser::AST::Entry::Posting::Account:D
)
{
    my %a;

    my Silo:D $s = ::($silo);
    my VarName:D $e = $entity;
    my VarName:D @p = @path if @path;

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
    --> TXN::Parser::AST::Entry::Posting::Amount:D
)
{
    my %a;

    my AssetCode:D $c = $asset-code;
    my Quantity:D $q = FatRat($asset-quantity);
    my AssetSymbol:D $s = $asset-symbol if $asset-symbol;
    my PlusMinus:D $p = $plus-or-minus if $plus-or-minus;

    %a<asset-code> = $c;
    %a<asset-quantity> = $q;
    %a<asset-symbol> = $s if $s;
    %a<plus-or-minus> = $p if $p;

    TXN::Parser::AST::Entry::Posting::Amount.new(|%a);
}

# --- end Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub from-hash(:%annot! --> TXN::Parser::AST::Entry::Posting::Annot:D)
{
    my %a;

    my TXN::Parser::AST::Entry::Posting::Annot::Inherit:D $inherit =
        from-hash(:inherit(%annot<inherit>)) if %annot<inherit>;
    my TXN::Parser::AST::Entry::Posting::Annot::Lot:D $lot =
        from-hash(:lot(%annot<lot>)) if %annot<lot>;
    my TXN::Parser::AST::Entry::Posting::Annot::XE:D $xe =
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
        :$asset-price!,
        :$asset-symbol
    )
    --> TXN::Parser::AST::Entry::Posting::Annot::Inherit:D
)
{
    my %i;

    my AssetCode:D $c = $asset-code;
    my Price:D $p = FatRat($asset-price);
    my AssetSymbol:D $s = $asset-symbol if $asset-symbol;

    %i<asset-code> = $c;
    %i<asset-price> = $p;
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
    --> TXN::Parser::AST::Entry::Posting::Annot::Lot:D
)
{
    my %l;

    my DecInc:D $d = ::($decinc);
    my VarName:D $n = $name;

    %l<decinc> = $d;
    %l<name> = $n;

    TXN::Parser::AST::Entry::Posting::Annot::Lot.new(|%l);
}

# --- end Entry::Posting::Annot::Lot }}}
# --- Entry::Posting::Annot::XE {{{

multi sub from-hash(
    :%xe! (
        :$asset-code!,
        :$asset-price!,
        :$asset-symbol
    )
    --> TXN::Parser::AST::Entry::Posting::Annot::XE:D
)
{
    my %x;

    my AssetCode:D $c = $asset-code;
    my Price:D $p = FatRat($asset-price);
    my AssetSymbol:D $s = $asset-symbol if $asset-symbol;

    %x<asset-code> = $c;
    %x<asset-price> = $p;
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
    --> TXN::Parser::AST::Entry::Posting::ID:D
)
{
    my %p;

    # XXX text → xxhash not checked
    my TXN::Parser::AST::Entry::ID:D $e = from-hash(:%entry-id);
    my UInt:D $n = $number;
    my Str:D $t = $text;
    my XXHash:D $x = $xxhash;

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

multi sub to-hash(TXN::Parser::AST::Entry:D @entry --> Array:D)
{
    my @a = @entry.map({ to-hash($_) });
}

multi sub to-hash(TXN::Parser::AST::Entry:D $entry --> Hash:D)
{
    $entry.hash;
}

# --- end Entry }}}

# end sub to-hash }}}

# hash ↔ json
# sub from-json {{{

sub from-json(Str:D $json --> Array:D)
{
    Rakudo::Internals::JSON.from-json($json).Array;
}

# end sub from-json }}}
# sub to-json {{{

multi sub to-json(@entry --> Str:D)
{
    Rakudo::Internals::JSON.to-json(@entry);
}

multi sub to-json(%entry --> Str:D)
{
    Rakudo::Internals::JSON.to-json(%entry);
}

# end sub to-json }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
