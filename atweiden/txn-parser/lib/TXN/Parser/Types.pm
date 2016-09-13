use v6;
use TXN::Parser::Grammar;
unit module TXN::Parser::Types;

# AssetCode {{{

subset AssetCode of Str is export where { is-asset-code($_) }

# --- sub is-asset-code {{{

multi sub is-asset-code(
    Str $s where { TXN::Parser::Grammar.parse($_, :rule<asset-code>).so }
) returns Bool
{
    True;
}

multi sub is-asset-code(
    Str $s where { TXN::Parser::Grammar.parse(.perl, :rule<asset-code>).so }
) returns Bool
{
    True;
}

multi sub is-asset-code($s) returns Bool {
    False;
}

# --- end sub is-asset-code }}}

# end AssetCode }}}
# AssetSymbol {{{

subset AssetSymbol of Str is export where
{
    TXN::Parser::Grammar.parse($_, :rule<asset-symbol>);
}

# end AssetSymbol }}}
# DecInc {{{

enum DecInc is export <DEC INC>;

# end DecInc }}}
# DrCr {{{

enum DrCr is export <DEBIT CREDIT>;

# end DrCr }}}
# PlusMinus {{{

subset PlusMinus of Str is export where
{
    TXN::Parser::Grammar.parse($_, :rule<plus-or-minus>);
}

# end PlusMinus }}}
# Quantity {{{

subset Quantity of FatRat is export where * >= 0;

# end Quantity }}}
# Silo {{{

enum Silo is export <ASSETS EXPENSES INCOME LIABILITIES EQUITY>;

# end Silo }}}
# VarName {{{

subset VarName of Str is export where { is-var-name($_) }

# --- sub is-var-name {{{

multi sub is-var-name(
    Str $s where { TXN::Parser::Grammar.parse($_, :rule<var-name>).so }
) returns Bool
{
    True;
}

multi sub is-var-name(
    Str $s where { TXN::Parser::Grammar.parse(.perl, :rule<var-name>).so }
) returns Bool
{
    True;
}

multi sub is-var-name($s) returns Bool {
    False;
}

# --- end sub is-var-name }}}

# end VarName }}}
# XXHash {{{

subset XXHash of Int is export;

# end XXHash }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
