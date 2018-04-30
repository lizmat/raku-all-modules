use v6;
use TXN::Parser::Types;
use X::TXN::Parser;

# Entry::ID {{{

class Entry::ID
{
    has UInt:D @.number is required;
    has XXHash:D $.xxhash is required;
    # causal text from accounting ledger
    has Str:D $.text is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<number> = @.number;
        %hash<text> = $.text;
        %hash<xxhash> = $.xxhash;
        %hash;
    }

    method Str(::?CLASS:D: --> Str:D)
    {
        my Str:D $xxhash = sprintf(Q{0x%s}, $.xxhash.base(16));
        my Str:D $s = sprintf(Q{[%s]:%s}, @.number.join(' '), $xxhash);
    }
}

# end Entry::ID }}}
# Entry::Header {{{

class Entry::Header
{
    has Dateish:D $.date is required;
    has Str $.description;
    has UInt:D $.important = 0;
    has VarName:D @.tag;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<date> = ~$.date;
        %hash<description> = $.description if $.description;
        %hash<important> = $.important;
        %hash<tag> = @.tag if @.tag;
        %hash;
    }
}

# end Entry::Header }}}
# Entry::Posting::Account {{{

class Entry::Posting::Account
{
    has Silo:D $.silo is required;
    has VarName:D $.entity is required;
    has VarName:D @.path;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<entity> = $.entity;
        %hash<path> = @.path if @.path;
        %hash<silo> = $.silo.gist;
        %hash;
    }
}

# end Entry::Posting::Account }}}
# Entry::Posting::Amount {{{

class Entry::Posting::Amount
{
    has AssetCode:D $.asset-code is required;
    has Quantity:D $.asset-quantity is required;
    has AssetSymbol $.asset-symbol;
    has PlusMinus $.plus-or-minus;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<asset-code> = $.asset-code;
        %hash<asset-quantity> = $.asset-quantity;
        %hash<asset-symbol> = $.asset-symbol if $.asset-symbol;
        %hash<plus-or-minus> = $.plus-or-minus if $.plus-or-minus;
        %hash;
    }
}

# end Entry::Posting::Amount }}}
# Entry::Posting::Annot::XE {{{

class Entry::Posting::Annot::XE
{
    has AssetCode:D $.asset-code is required;
    has Price:D $.asset-price is required;
    has AssetSymbol $.asset-symbol;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<asset-code> = $.asset-code;
        %hash<asset-price> = $.asset-price;
        %hash<asset-symbol> = $.asset-symbol if $.asset-symbol;
        %hash;
    }
}

# end Entry::Posting::Annot::XE }}}
# Entry::Posting::Annot::Inherit {{{

class Entry::Posting::Annot::Inherit is Entry::Posting::Annot::XE {*}

# end Entry::Posting::Annot::Inherit }}}
# Entry::Posting::Annot::Lot {{{

class Entry::Posting::Annot::Lot
{
    has VarName:D $.name is required;
    # is this lot being drawn down or filled up?
    has DecInc:D $.decinc is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<decinc> = $.decinc.gist;
        %hash<name> = $.name;
        %hash;
    }
}

# end Entry::Posting::Annot::Lot }}}
# Entry::Posting::Annot {{{

class Entry::Posting::Annot
{
    has Entry::Posting::Annot::Inherit $.inherit;
    has Entry::Posting::Annot::Lot $.lot;
    has Entry::Posting::Annot::XE $.xe;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<inherit> = $.inherit.hash if $.inherit;
        %hash<lot> = $.lot.hash if $.lot;
        %hash<xe> = $.xe.hash if $.xe;
        %hash;
    }
}

# end Entry::Posting::Annot }}}
# Entry::Posting::ID {{{

class Entry::Posting::ID
{
    # parent
    has Entry::ID:D $.entry-id is required;
    # scalar, because C<include>'d postings are forbidden
    has UInt:D $.number is required;
    has XXHash:D $.xxhash is required;
    # causal text from accounting ledger
    has Str:D $.text is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<entry-id> = $.entry-id.hash;
        %hash<number> = $.number;
        %hash<text> = $.text;
        %hash<xxhash> = $.xxhash;
        %hash;
    }

    method Str(::?CLASS:D: --> Str:D)
    {
        my Str:D $xxhash = sprintf(Q{0x%s}, $.xxhash.base(16));
        my Str:D $s = sprintf(Q{%s|%s:%s}, $.entry-id.Str, $.number, $xxhash);
    }
}

# end Entry::Posting::ID }}}
# Entry::Posting {{{

class Entry::Posting
{
    has Entry::Posting::ID:D $.id is required;
    has Entry::Posting::Account:D $.account is required;
    has Entry::Posting::Amount:D $.amount is required;
    has DecInc:D $.decinc is required;
    has DrCr:D $.drcr is required;
    has Entry::Posting::Annot $.annot;

    submethod BUILD(
        Entry::Posting::Account:D :$!account!,
        Entry::Posting::Amount:D :$!amount!,
        Entry::Posting::ID:D :$!id!,
        DecInc:D :$!decinc!,
        Entry::Posting::Annot :$annot
        --> Nil
    )
    {
        $!annot = $annot if $annot;
        $!drcr = gen-drcr($!account.silo, $!decinc);
    }

    method new(
        *%opts (
            Entry::Posting::Account:D :account($)!,
            Entry::Posting::Amount:D :amount($)!,
            Entry::Posting::ID:D :id($)!,
            DecInc:D :decinc($)!,
            Entry::Posting::Annot :annot($)
        )
        --> Entry::Posting:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<id> = $.id.hash;
        %hash<account> = $.account.hash;
        %hash<amount> = $.amount.hash;
        %hash<decinc> = $.decinc.gist;
        %hash<drcr> = $.drcr.gist;
        %hash<annot> = $.annot.hash if $.annot;
        %hash;
    }

    # assets and expenses increase on the debit side
    # +assets/expenses
    multi sub gen-drcr(ASSETS,      INC --> DrCr:D) { DEBIT }
    multi sub gen-drcr(EXPENSES,    INC --> DrCr:D) { DEBIT }
    # -assets/expenses
    multi sub gen-drcr(ASSETS,      DEC --> DrCr:D) { CREDIT }
    multi sub gen-drcr(EXPENSES,    DEC --> DrCr:D) { CREDIT }
    # income, liabilities and equity increase on the credit side
    # +income/liabilities/equity
    multi sub gen-drcr(INCOME,      INC --> DrCr:D) { CREDIT }
    multi sub gen-drcr(LIABILITIES, INC --> DrCr:D) { CREDIT }
    multi sub gen-drcr(EQUITY,      INC --> DrCr:D) { CREDIT }
    # -income/liabilities/equity
    multi sub gen-drcr(INCOME,      DEC --> DrCr:D) { DEBIT }
    multi sub gen-drcr(LIABILITIES, DEC --> DrCr:D) { DEBIT }
    multi sub gen-drcr(EQUITY,      DEC --> DrCr:D) { DEBIT }
}

# end Entry::Posting }}}
# Entry {{{

class Entry
{
    has Entry::ID:D $.id is required;
    has Entry::Header:D $.header is required;
    has Entry::Posting:D @.posting is required;

    submethod BUILD(
        Entry::ID:D :$!id!,
        Entry::Header:D :$!header!,
        Entry::Posting:D :@!posting!
        --> Nil
    )
    {*}

    method new(
        *%opts (
            Entry::ID:D :$id!,
            Entry::Header:D :header($)!,
            Entry::Posting:D :@posting!
        )
        --> Entry:D
    )
    {
        # verify entry is limited to one entity
        my UInt:D $number-entities =
            @posting.hyper.map({ .account.entity }).unique.elems;
        $number-entities == 1 or do {
            my Exception:U $exception-type =
                X::TXN::Parser::Entry::MultipleEntities;
            die($exception-type.new(:$number-entities, :entry-text($id.text)));
        }
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash;
        %hash<header> = $.header.hash;
        %hash<id> = $.id.hash;
        %hash<posting> = @.posting.hyper.map({ .hash }).Array;
        %hash;
    }
}

# end Entry }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
