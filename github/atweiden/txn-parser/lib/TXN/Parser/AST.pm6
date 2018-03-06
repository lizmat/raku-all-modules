use v6;
use TXN::Parser::Types;
use X::TXN::Parser;
unit class TXN::Parser::AST;

# TXN::Parser::AST::Entry::ID {{{

class Entry::ID
{
    has UInt:D @.number is required;
    has XXHash:D $.xxhash is required;

    # causal text from accounting ledger
    has Str:D $.text is required;

    method canonical(::?CLASS:D: --> Str:D)
    {
        $.number ~ ':' ~ $.xxhash;
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:@.number, :$.text, :$.xxhash);
    }
}

# end TXN::Parser::AST::Entry::ID }}}
# TXN::Parser::AST::Entry::Header {{{

class Entry::Header
{
    has Dateish:D $.date is required;
    has Str $.description;
    has UInt:D $.important = 0;
    has VarName:D @.tag;

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:date(~$.date), :$.description, :$.important, :@.tag);
    }
}

# end TXN::Parser::AST::Entry::Header }}}
# TXN::Parser::AST::Entry::Posting::Account {{{

class Entry::Posting::Account
{
    has Silo:D $.silo is required;
    has VarName:D $.entity is required;
    has VarName:D @.path;

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:$.entity, :@.path, :silo($.silo.gist));
    }
}

# end TXN::Parser::AST::Entry::Posting::Account }}}
# TXN::Parser::AST::Entry::Posting::Amount {{{

class Entry::Posting::Amount
{
    has AssetCode:D $.asset-code is required;
    has Quantity:D $.asset-quantity is required;
    has AssetSymbol $.asset-symbol;
    has PlusMinus $.plus-or-minus;

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:$.asset-code, :$.asset-quantity, :$.asset-symbol, :$.plus-or-minus);
    }
}

# end TXN::Parser::AST::Entry::Posting::Amount }}}
# TXN::Parser::AST::Entry::Posting::Annot::XE {{{

class Entry::Posting::Annot::XE
{
    has AssetCode:D $.asset-code is required;
    has Price:D $.asset-price is required;
    has AssetSymbol $.asset-symbol;

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:$.asset-code, :$.asset-price, :$.asset-symbol);
    }
}

# end TXN::Parser::AST::Entry::Posting::Annot::XE }}}
# TXN::Parser::AST::Entry::Posting::Annot::Inherit {{{

class Entry::Posting::Annot::Inherit is Entry::Posting::Annot::XE {*}

# end TXN::Parser::AST::Entry::Posting::Annot::Inherit }}}
# TXN::Parser::AST::Entry::Posting::Annot::Lot {{{

class Entry::Posting::Annot::Lot
{
    has VarName:D $.name is required;

    # is this lot being drawn down or filled up?
    has DecInc:D $.decinc is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:decinc($.decinc.gist), :$.name);
    }
}

# end TXN::Parser::AST::Entry::Posting::Annot::Lot }}}
# TXN::Parser::AST::Entry::Posting::Annot {{{

class Entry::Posting::Annot
{
    has Entry::Posting::Annot::Inherit $.inherit;
    has Entry::Posting::Annot::Lot $.lot;
    has Entry::Posting::Annot::XE $.xe;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %h;
        %h<inherit> = $.inherit ?? $.inherit.hash !! Nil;
        %h<lot> = $.lot ?? $.lot.hash !! Nil;
        %h<xe> = $.xe ?? $.xe.hash !! Nil;
        %h;
    }
}

# end TXN::Parser::AST::Entry::Posting::Annot }}}
# TXN::Parser::AST::Entry::Posting::ID {{{

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
        $.number ~ ':' ~ $.xxhash;
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        %(:entry-id($.entry-id.hash), :$.number, :$.text, :$.xxhash);
    }
}

# end TXN::Parser::AST::Entry::Posting::ID }}}
# TXN::Parser::AST::Entry::Posting {{{

class Entry::Posting
{
    has Entry::Posting::ID:D $.id is required;
    has Entry::Posting::Account:D $.account is required;
    has Entry::Posting::Amount:D $.amount is required;
    has DecInc:D $.decinc is required;
    has DrCr:D $.drcr is required;

    has Entry::Posting::Annot $.annot;

    # submethod BUILD {{{

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
        $!drcr = determine-debit-or-credit($!account.silo, $!decinc);
    }

    # end submethod BUILD }}}
    # method new {{{

    method new(
        *%opts (
            Entry::Posting::Account:D :$account!,
            Entry::Posting::Amount:D :$amount!,
            Entry::Posting::ID:D :$id!,
            DecInc:D :$decinc!,
            Entry::Posting::Annot :$annot
        )
        --> Entry::Posting:D
    )
    {
        self.bless(|%opts);
    }

    # end method new }}}

    # method hash {{{

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %h;
        %h<id> = $.id.hash;
        %h<account> = $.account.hash;
        %h<amount> = $.amount.hash;
        %h<decinc> = $.decinc.gist;
        %h<drcr> = $.drcr.gist;
        %h<annot> = $.annot ?? $.annot.hash !! Nil;
        %h;
    }

    # end method hash }}}

    # sub determine-debit-or-credit {{{

    # assets and expenses increase on the debit side

    # +assets/expenses
    multi sub determine-debit-or-credit(ASSETS, INC      --> DrCr:D) { DEBIT }
    multi sub determine-debit-or-credit(EXPENSES, INC    --> DrCr:D) { DEBIT }
    # -assets/expenses
    multi sub determine-debit-or-credit(ASSETS, DEC      --> DrCr:D) { CREDIT }
    multi sub determine-debit-or-credit(EXPENSES, DEC    --> DrCr:D) { CREDIT }

    # income, liabilities and equity increase on the credit side

    # +income/liabilities/equity
    multi sub determine-debit-or-credit(INCOME, INC      --> DrCr:D) { CREDIT }
    multi sub determine-debit-or-credit(LIABILITIES, INC --> DrCr:D) { CREDIT }
    multi sub determine-debit-or-credit(EQUITY, INC      --> DrCr:D) { CREDIT }
    # -income/liabilities/equity
    multi sub determine-debit-or-credit(INCOME, DEC      --> DrCr:D) { DEBIT }
    multi sub determine-debit-or-credit(LIABILITIES, DEC --> DrCr:D) { DEBIT }
    multi sub determine-debit-or-credit(EQUITY, DEC      --> DrCr:D) { DEBIT }

    # end sub determine-debit-or-credit }}}
}

# end TXN::Parser::AST::Entry::Posting }}}
# TXN::Parser::AST::Entry {{{

class Entry
{
    has Entry::ID:D $.id is required;
    has Entry::Header:D $.header is required;
    has Entry::Posting:D @.posting is required;

    # submethod BUILD {{{

    submethod BUILD(
        Entry::ID:D :$!id!,
        Entry::Header:D :$!header!,
        Entry::Posting:D :@!posting!
        --> Nil
    )
    {*}

    # end submethod BUILD }}}
    # method new {{{

    method new(
        *%opts (
            Entry::ID:D :$id!,
            Entry::Header:D :$header!,
            Entry::Posting:D :@posting!
        )
        --> Entry:D
    )
    {
        # verify entry is limited to one entity
        my UInt:D $number-entities =
            @posting.map({ .account.entity }).unique.elems;
        unless $number-entities == 1
        {
            die(
                X::TXN::Parser::Entry::MultipleEntities.new(
                    :$number-entities,
                    :entry-text($id.text)
                )
            );
        }

        self.bless(|%opts);
    }

    # end method new }}}

    # method hash {{{

    method hash(::?CLASS:D: --> Hash:D)
    {
        my @posting = @.posting.map({ .hash });
        %(:header($.header.hash), :id($.id.hash), :@posting);
    }

    # end method hash }}}
}

# end TXN::Parser::AST::Entry }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
