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

    method canonical(::?CLASS:D: --> Str:D)
    {
        my Str:D $canonical =
            sprintf(Q{[%s]:%s}, @.number.join(' '), $.xxhash);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my @number = @.number;
        my $text = $.text;
        my $xxhash = $.xxhash;
        my %hash = :@number, :$text, :$xxhash;
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
        my $date = ~$.date;
        my $description = $.description ?? $.description !! Nil;
        my $important = $.important;
        my @tag = @.tag ?? @.tag !! Nil;
        my %hash = :$date, :$description, :$important, :@tag;
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
        my $entity = $.entity;
        my @path = @.path ?? @.path !! Nil;
        my $silo = $.silo.gist;
        my %hash = :$entity, :@path, :$silo;
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
        my $asset-code = $.asset-code;
        my $asset-quantity = $.asset-quantity;
        my $asset-symbol = $.asset-symbol ?? $.asset-symbol !! Nil;
        my $plus-or-minus = $.plus-or-minus ?? $.plus-or-minus !! Nil;
        my %hash =
            :$asset-code,
            :$asset-quantity,
            :$asset-symbol,
            :$plus-or-minus;
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
        my $asset-code = $.asset-code;
        my $asset-price = $.asset-price;
        my $asset-symbol = $.asset-symbol ?? $.asset-symbol !! Nil;
        my %hash = :$asset-code, :$asset-price, :$asset-symbol;
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
        my $decinc = $.decinc.gist;
        my $name = $.name;
        my %hash = :$decinc, :$name;
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
        my %inherit = $.inherit ?? $.inherit.hash !! Nil;
        my %lot = $.lot ?? $.lot.hash !! Nil;
        my %xe = $.xe ?? $.xe.hash !! Nil;
        my %hash = :%inherit, :%lot, :%xe;
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

    method canonical(::?CLASS:D: --> Str:D)
    {
        my Str:D $canonical =
            sprintf(Q{%s|%s:%s}, $.entry-id.canonical, $.number, $.xxhash);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %entry-id = $.entry-id.hash;
        my $number = $.number;
        my $text = $.text;
        my $xxhash = $.xxhash;
        my %hash = :%entry-id, :$number, :$text, :$xxhash;
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

    # --- submethod BUILD {{{

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

    # --- end submethod BUILD }}}
    # --- method new {{{

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

    # --- end method new }}}

    # --- method hash {{{

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %id = $.id.hash;
        my %account = $.account.hash;
        my %amount = $.amount.hash;
        my $decinc = $.decinc.gist;
        my $drcr = $.drcr.gist;
        my %annot = $.annot ?? $.annot.hash !! Nil;
        my %hash = :%id, :%account, :%amount, :$decinc, :$drcr, :%annot;
    }

    # --- end method hash }}}

    # --- sub gen-drcr {{{

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

    # --- end sub gen-drcr }}}
}

# end Entry::Posting }}}
# Entry {{{

class Entry
{
    has Entry::ID:D $.id is required;
    has Entry::Header:D $.header is required;
    has Entry::Posting:D @.posting is required;

    # --- submethod BUILD {{{

    submethod BUILD(
        Entry::ID:D :$!id!,
        Entry::Header:D :$!header!,
        Entry::Posting:D :@!posting!
        --> Nil
    )
    {*}

    # --- end submethod BUILD }}}
    # --- method new {{{

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

    # --- end method new }}}

    # --- method hash {{{

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %header = $.header.hash;
        my %id = $.id.hash;
        my @posting = @.posting.hyper.map({ .hash });
        my %hash = :%header, :%id, :@posting;
    }

    # --- end method hash }}}
}

# end Entry }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
