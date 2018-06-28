use v6;

class CSS::Specification::Actions {

    # these actions translate a CSS property specification to Perl 6
    # rules or actions.
    has %.prop-refs is rw;
    has %.props is rw;
    has %.rules is rw;
    has %.child-props is rw;

    method TOP($/) { make $<def>>>.ast };

    method property-spec($/) {
        my @props = @($<prop-names>.ast);
        %.props{$_}++ for @props;

        my $spec = $<spec>.ast;

        my %prop-def = (
            props    => @props,
            synopsis => ~$<spec>,
            perl6    => $spec,
            );

        %prop-def<inherit> = .ast with $<inherit>;

        %prop-def<default> = ~$_
            with $<default>;

        make %prop-def;
    }

    method rule-spec($/) {

        my $rule = $<rule>.ast,
        my $perl6 = $<spec>.ast;
        my $synopsis = ~$<spec>;
        %.props{$rule}++;

        my %rule-def = (
            :$rule, :$synopsis, :$perl6
            );

        make %rule-def;
    }

    method yes($/) { make True }
    method no($/)  { make False }

    method spec($/) {
        my $spec = $<terms>.ast;
        $spec = ':my @*SEEN; ' ~ $spec
            if $*CHOICE;

        make $spec;
    }

    method prop-names($/) {
        my @prop-names = $<id>>>.ast;
        make @prop-names;
    }

    method id($/)        { make ~$/ }
    method id-quoted($/) { make $<id>.ast }
    method keyw($/)      { make $<id>.subst(/\-/, '\-'):g }
    method digits($/)    { make $/.Int }
    method rule($/)      { make $<id>.ast }

    method terms($/) {
        make @<term>>>.ast.join(' ');
    }

    method term-options($/) {
        my @choices = @<term>>>.ast;
        
        make @choices > 1
            ?? [~] '[ ', @choices.join(' || '), ' ]'
            !! @choices[0];
    }

    method !choose(@choices) {
        my $choices := @choices.map({[~] ($_, ' <!seen(', $*CHOICE++, ')>')}).join(' | ');
        return [~] '[ ', $choices, ' ]';
    }

    method term-combo($/) {
        my @choices = @<term>>>.ast;

        make @choices > 1
            ?? self!choose( @choices ) ~ '+'
            !! @choices[0];
    }

    method term-required($/) {
        my @choices = $<term>>>.ast;

        make @choices > 1
            ?? [~] self!choose( @choices ), '**', @choices.Int
            !! @choices[0];
    }

    method term-values($/) {
        make @<term>>>.ast.join(' ');
    }

    method term($/) {
        my $value = $<value>.ast;
        $value ~= .ast
            with $<occurs>;

        make $value;
    }

    method occurs:sym<maybe>($/)     { make '?' }
    method occurs:sym<once-plus>($/) { make '+' }
    method occurs:sym<zero-plus>($/) { make '*' }
    method occurs:sym<list>($/)      {
        my $quant = $<range> ?? $<range>.ast !! '+';
        make "{$quant}% <op(',')>"
    }
    method occurs:sym<range>($/)     { make $<range>.ast }
    method range($/) {
        my $range = ' ** ' ~ $<min>.ast;
        $range ~= '..' ~ $<max>.ast
            if $<max>;

        make $range;
    }

    method value:sym<func>($/)     {
        # todo - save function prototype
        %.prop-refs{ ~$<id>.ast }++;
        make [~] '<', $<id>.ast, '>';
    }

    method value:sym<keywords>($/) {
        my $keywords = @<keyw> > 1
            ?? [~] '[ ', @<keyw>>>.ast.join(' | '), ' ]'
            !! @<keyw>[0].ast;

        make $keywords ~ ' & <keyw>';
    }

    method value:sym<keyw-quant>($/) {
        make [~] '[ ', $<keyw>.ast, ' & <keyw> ]', $<occurs>.ast
    }

    method value:sym<numbers>($/) {
        my $keywords = @<digits> > 1
            ?? [~] '[ ', @<digits>>>.ast.join(' | '), ' ]'
            !! @<digits>[0].ast;

        make $keywords ~ ' & <number>';
    }

    method value:sym<num-quant>($/) {
        make [~] '[ ', $<digits>.ast, ' & <number> ]', $<occurs>.ast
    }

    method value:sym<group>($/) {
        my $val = $<terms>.ast;
        make [~] '[ ', $val, ' ]';
    }

    method value:sym<rule>($/) {
        my $val = ~$<rule>.ast;
        %.prop-refs{ $val }++;
        make [~] '<', $val, '>'
    }

    method value:sym<op>($/)     { make [~] "<op('", $/.trim, "')>" }

    method property-ref:sym<css21>($/) { make $<id>.ast }
    method property-ref:sym<css3>($/)  { make $<id>.ast }
    method value:sym<prop-ref>($/)        {
        my $prop-ref = $<property-ref>.ast;
        %.prop-refs{ 'expr-' ~ $prop-ref }++;
        %.child-props{$_}.push: $prop-ref for @*PROP-NAMES; 
        make [~] '<expr-', $prop-ref, '>';
    }

    method value:sym<literal>($/)  { make [~] "'", ~$0, "'" }

    method value:sym<num>($/)      { make ~$/ }

    method value:sym<keyw>($/)     { make ~$/ }
}
