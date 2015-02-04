use v6;

class CSS::Module::CSS21::Actions { ... }

use CSS::Specification::Terms::Actions;
use CSS::Module::CSS21::Spec::Interface;
use CSS::Module::CSS21::Spec::Actions;
use CSS::Grammar::Actions;

class CSS::ModuleX::CSS21::Actions
    is CSS::Module::CSS21::Spec::Actions {

    method color:sym<system>($/) { make $.node($/) }

    # --- Functions --- #

    #| usage: attr( attribute-name <type-or-unit>? )
    method attr($/)             {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'attr', $.list($/) );
    }

    #| usage: counter(ident [, ident [,...] ])
    method counter($/) {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'counter', $.list($/) );
    }

    #| usage: counters(ident [, "string"])
    method counters($/) {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'counters', $.list($/) );
    }

    #| usage: rect(<top>, <right>, <botom>, <left>)
    method shape($/)     {
        return $.warning(&?ROUTINE.WHY)
            if $<any-args>;
        make $.func( 'rect', $.list($/) );
    }

   # --- Expressions --- #

    method border-style($/)   { make $.list($/) }
    method border-width($/)   { make $.list($/) }
    method family-name($/)    { make $<family-name>.ast }
    method generic-family($/) { make $<keyw>.ast }
    method absolute-size($/)  { make $<keyw>.ast }
    method relative-size($/)  { make $<keyw>.ast }
    method margin-width($/)   { make $.node($/) }
    method padding-width($/)  { make $.node($/) }
    method generic-voice($/)  { make $<keyw>.ast }
    method specific-voice($/) { make $<value>.ast }
}

class CSS::Module::CSS21::Actions
    is CSS::ModuleX::CSS21::Actions
    is CSS::Specification::Terms::Actions 
    is CSS::Grammar::Actions
    does CSS::Module::CSS21::Spec::Interface {

    has @._proforma = 'inherit';

}
