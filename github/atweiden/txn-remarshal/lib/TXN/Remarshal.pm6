use v6;
use TXN::Parser;
use TXN::Parser::ParseTree;
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
    my Entry:D @entry = from-txn($txn);
}

multi sub remarshal(
    Entry:D @entry,
    'ENTRY',
    'TXN'
    --> Str:D
)
{
    my Str:D $txn = to-txn(@entry);
}

multi sub remarshal(
    Entry:D $entry,
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
    Entry:D @entry,
    'ENTRY',
    'HASH'
    --> Array:D
)
{
    my @e = to-hash(@entry);
}

multi sub remarshal(
    Entry:D $entry,
    'ENTRY',
    'HASH'
    --> Hash:D
)
{
    my %e = to-hash($entry);
}

multi sub remarshal(@e, 'HASH', 'ENTRY' --> Array:D)
{
    my Entry:D @entry = from-hash(:entry(@e));
}

multi sub remarshal(%e, 'HASH', 'ENTRY' --> Entry:D)
{
    my Entry:D $entry = from-hash(:entry(%e));
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
    my Entry:D @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
}

multi sub remarshal(@e, 'HASH', 'TXN' --> Str:D)
{
    my Entry:D @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str:D $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ hash }}}
# --- txn ↔ json {{{

multi sub remarshal(Str:D $txn, 'TXN', 'JSON' --> Str:D)
{
    my Entry:D @entry = remarshal($txn, 'TXN', 'ENTRY');
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str:D $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(Str:D $json, 'JSON', 'TXN' --> Str:D)
{
    my @e = remarshal($json, 'JSON', 'HASH');
    my Entry:D @entry = remarshal(@e, 'HASH', 'ENTRY');
    my Str:D $txn = remarshal(@entry, 'ENTRY', 'TXN');
}

# --- end txn ↔ json }}}
# ------------------------------------------------------------------------------
# --- entry ↔ json {{{

multi sub remarshal(
    Entry:D @entry,
    'ENTRY',
    'JSON'
    --> Str:D
)
{
    my @e = remarshal(@entry, 'ENTRY', 'HASH');
    my Str:D $json = remarshal(@e, 'HASH', 'JSON');
}

multi sub remarshal(
    Entry:D $entry,
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
    my Entry:D @entry = TXN::Parser.parse($content, |%opts).made;
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
    my Entry:D @entry = TXN::Parser.parsefile($file, |%opts).made;
}

# end sub from-txn }}}
# sub to-txn {{{

# --- Entry {{{

multi sub to-txn(Entry:D @entry --> Str:D) is export
{
    @entry.map({ to-txn($_) }).join("\n" x 2);
}

multi sub to-txn(Entry:D $entry --> Str:D) is export
{
    my Entry::Header:D $header = $entry.header;
    my Entry::Posting:D @posting = $entry.posting;
    my Str:D $s = join("\n", to-txn($header), to-txn(@posting));
    $s;
}

# --- end Entry }}}
# --- Entry::Header {{{

multi sub to-txn(Entry::Header:D $header --> Str:D)
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
        my Str:D $d = qq:to/EOF/.trim;
        '''
        $description
        '''
        EOF
        $s ~= "\n" ~ $d;
    }

    $s.trim;
}

# --- end Entry::Header }}}
# --- Entry::Posting {{{

multi sub to-txn(Entry::Posting:D @posting --> Str:D)
{
    @posting.map({ to-txn($_) }).join("\n");
}

multi sub to-txn(Entry::Posting:D $posting --> Str:D)
{
    my Entry::Posting::Account:D $account = $posting.account;
    my Entry::Posting::Amount:D $amount = $posting.amount;
    my DecInc:D $decinc = $posting.decinc;
    my Entry::Posting::Annot:D $annot = $posting.annot if $posting.annot;

    my Bool:D $needs-minus = so($decinc ~~ DEC);

    # check if $amount includes C<:plus-or-minus('-')>
    # if so, we don't need to negate the posting amount
    my Bool:D $has-minus = $amount.plus-or-minus
        ?? $amount.plus-or-minus eq '-'
        !! False;

    my Str:D $s = to-txn($account) ~ ' ' x 4;
    if $needs-minus
    {
        $s ~= '-' unless $has-minus;
    }

    $s ~= to-txn($amount);
    $s ~= ' ' ~ to-txn($annot) if $annot;
    $s;
}

# --- end Entry::Posting }}}
# --- Entry::Posting::Account {{{

multi sub to-txn(
    Entry::Posting::Account:D $account
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
    Entry::Posting::Amount:D $amount
    --> Str:D
)
{
    my AssetCode:D $asset-code = $amount.asset-code;
    my Quantity:D $asset-quantity = $amount.asset-quantity;
    my AssetSymbol:D $asset-symbol =
        $amount.asset-symbol if $amount.asset-symbol;
    my PlusMinus:D $plus-or-minus =
        $amount.plus-or-minus if $amount.plus-or-minus;

    my Str:D $s = '';
    $s ~= $plus-or-minus if $plus-or-minus;
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub to-txn(Entry::Posting::Annot:D $annot --> Str:D)
{
    my Entry::Posting::Annot::Inherit:D $inherit =
        $annot.inherit if $annot.inherit;
    my Entry::Posting::Annot::Lot:D $lot =
        $annot.lot if $annot.lot;
    my Entry::Posting::Annot::XE:D $xe =
        $annot.xe if $annot.xe;

    my Str:D @a;
    push(@a, to-txn($xe)) if $xe;
    push(@a, to-txn($inherit)) if $inherit;
    push(@a, to-txn($lot)) if $lot;

    my Str:D $s = '';
    $s ~= join(' ', @a);
    $s;
}

# --- end Entry::Posting::Annot }}}
# --- Entry::Posting::Annot::Inherit {{{

multi sub to-txn(
    Entry::Posting::Annot::Inherit:D $inherit
    --> Str:D
)
{
    my AssetCode:D $asset-code = $inherit.asset-code;
    my Price:D $asset-price = $inherit.asset-price;
    my AssetSymbol:D $asset-symbol =
        $inherit.asset-symbol if $inherit.asset-symbol;

    my Str:D $s = '« ';
    $s ~= $asset-symbol if $asset-symbol;
    $s ~= $asset-price;
    $s ~= ' ' ~ $asset-code;
    $s;
}

# --- end Entry::Posting::Annot::Inherit }}}
# --- Entry::Posting::Annot::Lot {{{

multi sub to-txn(
    Entry::Posting::Annot::Lot:D $lot
    --> Str:D
)
{
    my VarName:D $name = $lot.name;
    my DecInc:D $decinc = $lot.decinc;
    my Str:D $s = do given $decinc
    {
        when DEC { '←' }
        when INC { '→' }
    }
    $s ~= ' [' ~ $name ~ ']';
    $s;
}

# --- end Entry::Posting::Annot::Lot }}}
# --- Entry::Posting::Annot::XE {{{

multi sub to-txn(
    Entry::Posting::Annot::XE:D $xe
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
    my Entry:D @e = @entry.map({ from-hash(:entry($_)) });
}

multi sub from-hash(
    :entry(%)! (
        :%header!,
        :id(%entry-id)!,
        :@posting!
    )
    --> Entry:D
)
{
    my %entry;

    my Entry::Header:D $headerʹ = from-hash(:%header);
    my Entry::ID:D $entry-idʹ = from-hash(:%entry-id);
    my Entry::Posting:D @postingʹ = from-hash(:@posting);

    %entry<header> = $headerʹ;
    %entry<id> = $entry-idʹ;
    %entry<posting> = @postingʹ;

    Entry.new(|%entry);
}

# --- end Entry }}}
# --- Entry::Header {{{

multi sub from-hash(
    :header(%)! (
        :$date!,
        :$description,
        :$important,
        :@tag
    )
    --> Entry::Header:D
)
{
    my %header;

    my TXN::Parser::Actions:D $actions = TXN::Parser::Actions.new;
    my Dateish:D $dateʹ =
        TXN::Parser::Grammar.parse($date, :rule<date>, :$actions).made;
    my Str:D $descriptionʹ = $description if $description;
    my UInt:D $importantʹ = $important if $important;
    my Str:D @tagʹ = @tag if @tag;

    %header<date> = $dateʹ;
    %header<description> = $descriptionʹ if $descriptionʹ;
    %header<important> = $importantʹ if $importantʹ;

    Entry::Header.new(|%header, :tag(@tagʹ));
}

# --- end Entry::Header }}}
# --- Entry::ID {{{

multi sub from-hash(
    :entry-id(%)! (
        :@number!,
        :$text!,
        :$xxhash!
    )
    --> Entry::ID:D
)
{
    my %entry-id;

    my UInt:D @numberʹ = @number;
    my Str:D $textʹ = $text;
    my XXHash:D $xxhashʹ = $xxhash;

    %entry-id<text> = $textʹ;
    %entry-id<xxhash> = $xxhashʹ;

    # XXX text → xxhash not checked
    Entry::ID.new(|%entry-id, :number(@numberʹ));
}

# --- end Entry::ID }}}
# --- Entry::Posting {{{

multi sub from-hash(:@posting! --> Array:D)
{
    my Entry::Posting:D @p = @posting.map({ from-hash(:posting($_)) });
}

multi sub from-hash(
    :posting(%)! (
        :%account!,
        :%amount!,
        :$decinc!,
        :id(%posting-id)!,
        :%annot
    )
    --> Entry::Posting:D
)
{
    my %posting;

    my Entry::Posting::Account:D $accountʹ = from-hash(:%account);
    my Entry::Posting::Amount:D $amountʹ = from-hash(:%amount);
    my Entry::Posting::Annot:D $annotʹ = from-hash(:%annot) if %annot;
    my Entry::Posting::ID:D $posting-idʹ = from-hash(:%posting-id);
    my DecInc:D $decincʹ = ::($decinc);

    %posting<account> = $accountʹ;
    %posting<amount> = $amountʹ;
    %posting<annot> = $annotʹ if $annotʹ;
    %posting<id> = $posting-idʹ;
    %posting<decinc> = $decincʹ;

    Entry::Posting.new(|%posting);
}

# --- end Entry::Posting }}}
# --- Entry::Posting::Account {{{

multi sub from-hash(
    :account(%)! (
        :$silo!,
        :$entity!,
        :@path
    )
    --> Entry::Posting::Account:D
)
{
    my %account;

    my Silo:D $siloʹ = ::($silo);
    my VarName:D $entityʹ = $entity;
    my VarName:D @pathʹ = @path if @path;

    %account<silo> = $siloʹ;
    %account<entity> = $entityʹ;

    Entry::Posting::Account.new(|%account, :path(@pathʹ));
}

# --- end Entry::Posting::Account }}}
# --- Entry::Posting::Amount {{{

multi sub from-hash(
    :amount(%)! (
        :$asset-code!,
        :$asset-quantity!,
        :$asset-symbol,
        :$plus-or-minus
    )
    --> Entry::Posting::Amount:D
)
{
    my %amount;

    my AssetCode:D $asset-codeʹ = $asset-code;
    my Quantity:D $asset-quantityʹ = FatRat($asset-quantity);
    my AssetSymbol:D $asset-symbolʹ = $asset-symbol if $asset-symbol;
    my PlusMinus:D $plus-or-minusʹ = $plus-or-minus if $plus-or-minus;

    %amount<asset-code> = $asset-codeʹ;
    %amount<asset-quantity> = $asset-quantityʹ;
    %amount<asset-symbol> = $asset-symbolʹ if $asset-symbolʹ;
    %amount<plus-or-minus> = $plus-or-minusʹ if $plus-or-minusʹ;

    Entry::Posting::Amount.new(|%amount);
}

# --- end Entry::Posting::Amount }}}
# --- Entry::Posting::Annot {{{

multi sub from-hash(
    :annot(%)! (
        :%inherit,
        :%lot,
        :%xe
    )
    --> Entry::Posting::Annot:D
)
{
    my %annot;

    my Entry::Posting::Annot::Inherit:D $inheritʹ =
        from-hash(:%inherit) if %inherit;
    my Entry::Posting::Annot::Lot:D $lotʹ =
        from-hash(:%lot) if %lot;
    my Entry::Posting::Annot::XE:D $xeʹ =
        from-hash(:%xe) if %xe;

    %annot<inherit> = $inheritʹ if $inheritʹ;
    %annot<lot> = $lotʹ if $lotʹ;
    %annot<xe> = $xeʹ if $xeʹ;

    Entry::Posting::Annot.new(|%annot);
}

# --- end Entry::Posting::Annot }}}
# --- Entry::Posting::Annot::Inherit {{{

multi sub from-hash(
    :inherit(%)! (
        :$asset-code!,
        :$asset-price!,
        :$asset-symbol
    )
    --> Entry::Posting::Annot::Inherit:D
)
{
    my %inherit;

    my AssetCode:D $asset-codeʹ = $asset-code;
    my Price:D $asset-priceʹ = FatRat($asset-price);
    my AssetSymbol:D $asset-symbolʹ = $asset-symbol if $asset-symbol;

    %inherit<asset-code> = $asset-codeʹ;
    %inherit<asset-price> = $asset-priceʹ;
    %inherit<asset-symbol> = $asset-symbolʹ if $asset-symbolʹ;

    Entry::Posting::Annot::Inherit.new(|%inherit);
}

# --- end Entry::Posting::Annot::Inherit }}}
# --- Entry::Posting::Annot::Lot {{{

multi sub from-hash(
    :lot(%)! (
        :$decinc!,
        :$name!
    )
    --> Entry::Posting::Annot::Lot:D
)
{
    my %lot;

    my DecInc:D $decincʹ = ::($decinc);
    my VarName:D $nameʹ = $name;

    %lot<decinc> = $decincʹ;
    %lot<name> = $nameʹ;

    Entry::Posting::Annot::Lot.new(|%lot);
}

# --- end Entry::Posting::Annot::Lot }}}
# --- Entry::Posting::Annot::XE {{{

multi sub from-hash(
    :xe(%)! (
        :$asset-code!,
        :$asset-price!,
        :$asset-symbol
    )
    --> Entry::Posting::Annot::XE:D
)
{
    my %xe;

    my AssetCode:D $asset-codeʹ = $asset-code;
    my Price:D $asset-priceʹ = FatRat($asset-price);
    my AssetSymbol:D $asset-symbolʹ = $asset-symbol if $asset-symbol;

    %xe<asset-code> = $asset-codeʹ;
    %xe<asset-price> = $asset-priceʹ;
    %xe<asset-symbol> = $asset-symbolʹ if $asset-symbolʹ;

    Entry::Posting::Annot::XE.new(|%xe);
}

# --- end Entry::Posting::Annot::XE }}}
# --- Entry::Posting::ID {{{

multi sub from-hash(
    :posting-id(%)! (
        :%entry-id!,
        :$number!,
        :$text!,
        :$xxhash!
    )
    --> Entry::Posting::ID:D
)
{
    my %posting-id;

    # XXX text → xxhash not checked
    my Entry::ID:D $entry-idʹ = from-hash(:%entry-id);
    my UInt:D $numberʹ = $number;
    my Str:D $textʹ = $text;
    my XXHash:D $xxhashʹ = $xxhash;

    %posting-id<entry-id> = $entry-idʹ;
    %posting-id<number> = $numberʹ;
    %posting-id<text> = $textʹ;
    %posting-id<xxhash> = $xxhashʹ;

    Entry::Posting::ID.new(|%posting-id);
}

# --- end Entry::Posting::ID }}}

# end sub from-hash }}}
# sub to-hash {{{

# --- Entry {{{

multi sub to-hash(Entry:D @entry --> Array:D)
{
    my @a = @entry.map({ to-hash($_) });
}

multi sub to-hash(Entry:D $entry --> Hash:D)
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
