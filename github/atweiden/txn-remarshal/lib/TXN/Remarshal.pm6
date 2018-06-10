use v6;
use TXN::Parser;
use TXN::Parser::ParseTree;
use TXN::Parser::Types;
unit module TXN::Remarshal;

# remarshal {{{

# --- format {{{

subset Format of Str where /HASH|JSON|LEDGER|TXN/;
multi sub gen-format('hash'   --> Format:D) { 'HASH' }
multi sub gen-format('json'   --> Format:D) { 'JSON' }
multi sub gen-format('ledger' --> Format:D) { 'LEDGER' }
multi sub gen-format('txn'    --> Format:D) { 'TXN' }

# --- end format }}}

multi sub remarshal(
    $input,
    Str:D :if(:$input-format) where /hash|json|ledger|txn/,
    Str:D :of(:$output-format) where /hash|json|ledger|txn/
) is export
{
    my Format:D $if = gen-format($input-format);
    my Format:D $of = gen-format($output-format);
    remarshal($input, $if, $of);
}

# ------------------------------------------------------------------------------
# --- no conversion required {{{

multi sub remarshal($input, 'HASH', 'HASH') { $input }
multi sub remarshal($input, 'JSON', 'JSON') { $input }
multi sub remarshal($input, 'LEDGER', 'LEDGER') { $input }
multi sub remarshal($input, 'TXN', 'TXN') { $input }

# --- end no conversion required }}}
# ------------------------------------------------------------------------------
# --- txn ↔ ledger {{{

multi sub remarshal(
    Str:D $txn,
    'TXN',
    'LEDGER'
    --> Ledger:D
)
{
    my Ledger:D $ledger = from-txn($txn);
}

multi sub remarshal(
    Ledger:D $ledger,
    'LEDGER',
    'TXN'
    --> Str:D
)
{
    my Str:D $txn = to-txn($ledger);
}

# --- end txn ↔ ledger }}}
# --- ledger ↔ hash {{{

multi sub remarshal(
    Ledger:D $ledger,
    'LEDGER',
    'HASH'
    --> Hash:D
)
{
    my %ledger = to-hash($ledger);
}

multi sub remarshal(%ledger, 'HASH', 'LEDGER' --> Ledger:D)
{
    my Ledger:D $ledger = from-hash(:%ledger);
}

# --- end ledger ↔ hash }}}
# --- hash ↔ json {{{

multi sub remarshal(%ledger, 'HASH', 'JSON' --> Str:D)
{
    my Str:D $json = to-json(%ledger);
}

multi sub remarshal(Str:D $json, 'JSON', 'HASH' --> Hash:D)
{
    my %ledger = from-json($json);
}

# --- end hash ↔ json }}}
# ------------------------------------------------------------------------------
# --- txn ↔ hash {{{

multi sub remarshal(Str:D $txn, 'TXN', 'HASH' --> Hash:D)
{
    my Ledger:D $ledger = remarshal($txn, 'TXN', 'LEDGER');
    my %ledger = remarshal($ledger, 'LEDGER', 'HASH');
}

multi sub remarshal(%ledger, 'HASH', 'TXN' --> Str:D)
{
    my Ledger:D $ledger = remarshal(%ledger, 'HASH', 'LEDGER');
    my Str:D $txn = remarshal(%ledger, 'LEDGER', 'TXN');
}

# --- end txn ↔ hash }}}
# --- txn ↔ json {{{

multi sub remarshal(Str:D $txn, 'TXN', 'JSON' --> Str:D)
{
    my Ledger:D $ledger = remarshal($txn, 'TXN', 'LEDGER');
    my %ledger = remarshal($ledger, 'LEDGER', 'HASH');
    my Str:D $json = remarshal(%ledger, 'HASH', 'JSON');
}

multi sub remarshal(Str:D $json, 'JSON', 'TXN' --> Str:D)
{
    my %ledger = remarshal($json, 'JSON', 'HASH');
    my Ledger:D $ledger = remarshal(%ledger, 'HASH', 'LEDGER');
    my Str:D $txn = remarshal($ledger, 'LEDGER', 'TXN');
}

# --- end txn ↔ json }}}
# ------------------------------------------------------------------------------
# --- ledger ↔ json {{{

multi sub remarshal(
    Ledger:D $ledger,
    'LEDGER',
    'JSON'
    --> Str:D
)
{
    my %ledger = remarshal($ledger, 'LEDGER', 'HASH');
    my Str:D $json = remarshal(%ledger, 'HASH', 'JSON');
}

# --- end ledger ↔ json }}}
# ------------------------------------------------------------------------------

# end remarshal }}}

# txn ↔ ledger
# sub from-txn {{{

multi sub from-txn(
    Str:D $txn,
    *%opts (
        Str :include-lib($),
        Int :date-local-offset($)
    )
    --> Ledger:D
) is export
{
    my Ledger:D $ledger = TXN::Parser.parse($txn, |%opts).made;
}

multi sub from-txn(
    Str:D :$file! where .so,
    *%opts (
        Str :include-lib($),
        Int :date-local-offset($)
    )
    --> Ledger:D
) is export
{
    my Ledger:D $ledger = TXN::Parser.parsefile($file, |%opts).made;
}

# end sub from-txn }}}
# sub to-txn {{{

# --- Ledger {{{

multi sub to-txn(Ledger:D $ledger --> Str:D) is export
{
    my Entry:D @entry = $ledger.entry;
    my Str:D $s = to-txn(@entry);
}

# --- end Ledger }}}
# --- Entry {{{

multi sub to-txn(Entry:D @entry --> Str:D) is export
{
    my Str:D $s = @entry.map({ .&to-txn }).join("\n" x 2);
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
    $s ~= "\n" ~ @tag.map(-> VarName:D $tag { '#' ~ $tag }).join(' ') if @tag;
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
    @posting.map({ .&to-txn }).join("\n");
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
    my Bool:D $has-minus =
        $amount.plus-or-minus ?? $amount.plus-or-minus eq '-' !! False;

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
    Entry::Posting::Amount[ASSET] $amount
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

multi sub to-txn(
    Entry::Posting::Amount[COMMODITY] $amount
    --> Str:D
)
{
    my UnitOfMeasure:D $unit-of-measure = $amount.unit-of-measure;
    my AssetCode:D $asset-code = $amount.asset-code;
    my Quantity:D $asset-quantity = $amount.asset-quantity;
    my PlusMinus:D $plus-or-minus =
        $amount.plus-or-minus if $amount.plus-or-minus;

    my Str:D $s = '';
    $s ~= $plus-or-minus if $plus-or-minus;
    $s ~= $asset-quantity;
    $s ~= ' ' ~ $unit-of-measure ~ ' of';
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

# ledger ↔ hash
# sub from-hash {{{

# --- Ledger {{{

multi sub from-hash(:ledger(%)! (:@entry!) --> Ledger:D)
{
    my Entry:D @e = from-hash(:@entry);
    Ledger.new(:entry(@e));
}

# --- end Ledger }}}
# --- Entry {{{

multi sub from-hash(:@entry! --> Array:D)
{
    my Entry:D @e = @entry.map(-> %entry { from-hash(:%entry) });
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
    my Entry::Posting:D @p = @posting.map(-> %posting { from-hash(:%posting) });
}

multi sub from-hash(
    :posting(%)! (
        :%account!,
        :%amount!,
        :$decinc!,
        :id(%posting-id)!,
        :%annot,
        *%
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
    my Quantity:D $asset-quantityʹ = Rat($asset-quantity);
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
    my Price:D $asset-priceʹ = Rat($asset-price);
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
    my Price:D $asset-priceʹ = Rat($asset-price);
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

# --- Ledger {{{

multi sub to-hash(Ledger:D $ledger --> Hash:D)
{
    $ledger.hash;
}

# --- end Ledger }}}

# end sub to-hash }}}

# hash ↔ json
# sub from-json {{{

sub from-json(Str:D $json --> Hash:D)
{
    my %ledger = Rakudo::Internals::JSON.from-json($json);
}

# end sub from-json }}}
# sub to-json {{{

multi sub to-json(%ledger --> Str:D)
{
    Rakudo::Internals::JSON.to-json(%ledger);
}

# end sub to-json }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
