use v6;
use TXN::Parser::Grammar;
unit module TXN::Parser::Types;

# AssetCode {{{

subset AssetCode of Str is export where
{
    TXN::Parser::Grammar.parse($_, :rule<asset-code>);
}

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

subset VarName of Str is export where
{
    TXN::Parser::Grammar.parse($_, :rule<var-name>);
}

# end VarName }}}
# XXHash {{{

subset XXHash of Int is export;

# end XXHash }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
