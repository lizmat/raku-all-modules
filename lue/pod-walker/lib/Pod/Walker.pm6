# Walker.pm6 --- class and functions for walking a Pod tree.

use v6;

sub def_callee($text, *@a, *%b) {
    $text;
}

class Walker::Callees {
    has %!funcs;

    has $.debug = False;

    submethod BUILD(:$!debug, *%OPTS) {
        for <para named comment code declarator table fcode heading item config plain> {
            %!funcs{$_} = %OPTS{$_} // &def_callee;
        }
    }

    method new(:$debug = False, :&para, :&named, :&comment, :&code, :&declarator,
               :&table, :&fcode, :&heading, :&item, :&config, :&plain) {
        self.bless(:$debug, :&para, :&named, :&comment, :&code,
            :&declarator, :&table, :&fcode, :&heading,
            :&item, :&config, :&plain);
    }

    method debug-ON { $!debug = True; }
    method debug-OFF { $!debug = False; }

    method set-para(&f)       { %!funcs<para>       = &f; }
    method set-named(&f)      { %!funcs<named>      = &f; }
    method set-comment(&f)    { %!funcs<comment>    = &f; }
    method set-code(&f)       { %!funcs<code>       = &f; }
    method set-declarator(&f) { %!funcs<declarator> = &f; }
    method set-table(&f)      { %!funcs<table>      = &f; }
    method set-fcode(&f)      { %!funcs<fcode>      = &f; }
    method set-heading(&f)    { %!funcs<heading>    = &f; }
    method set-item(&f)       { %!funcs<item>       = &f; }
    method set-config(&f)     { %!funcs<config>     = &f; }
    method set-plain(&f)      { %!funcs<plain>      = &f; }

    method para(|a)       { note "Called para"       if $!debug; %!funcs<para>\     .(|a) }
    method named(|a)      { note "Called named"      if $!debug; %!funcs<named>\    .(|a) }
    method comment(|a)    { note "Called comment"    if $!debug; %!funcs<comment>\  .(|a) }
    method code(|a)       { note "Called code"       if $!debug; %!funcs<code>\     .(|a) }
    method declarator(|a) { note "Called declarator" if $!debug; %!funcs<declarator>.(|a) }
    method table(|a)      { note "Called table"      if $!debug; %!funcs<table>\    .(|a) }
    method fcode(|a)      { note "Called fcode"      if $!debug; %!funcs<fcode>\    .(|a) }
    method heading(|a)    { note "Called heading"    if $!debug; %!funcs<heading>\  .(|a) }
    method item(|a)       { note "Called item"       if $!debug; %!funcs<item>\     .(|a) }
    method config(|a)     { note "Called config"     if $!debug; %!funcs<config>\   .(|a) }
    method plain(|a)      { note "Called plain"      if $!debug; %!funcs<plain>\    .(|a) }
}

# I know Pod::Config !~~ Pod::Block, but hopefully you're not using one as a
# top-level node anyway :) .
sub pod-walk(Walker::Callees $wc, Pod::Block $START) is export {
    return pw-recurse($wc, $START, 0);
}

proto sub pw-recurse($wc, $node, $level) {
    note "LEVEL $level".indent($level * 2) if $wc.debug;

    my @*TEXT;
    if $node ~~ Pod::Block {
            
        for $node.content {
            @*TEXT.push(pw-recurse($wc, $_, $level+1));
        }
    }

    {*}
}

multi sub pw-recurse($wc, Pod::Block::Para $node, $level) {
    $wc.para(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Named $node, $level) {
    $wc.named(@*TEXT, $node.name);
}

multi sub pw-recurse($wc, Pod::Block::Comment $node, $level) {
    $wc.comment(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Code $node, $level) {
    $wc.code(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Declarator $node, $level) {
    $wc.declarator(@*TEXT, $node.WHEREFORE);
}

multi sub pw-recurse($wc, Pod::Block::Table $node, $level) {
    $wc.table(@*TEXT, $node.headers, $node.caption);
}

multi sub pw-recurse($wc, Pod::FormattingCode $node, $level) {
    $wc.fcode(@*TEXT, $node.type, $node.meta);
}

multi sub pw-recurse($wc, Pod::Heading $node, $level) {
    $wc.heading(@*TEXT, $node.level // Any);
}

multi sub pw-recurse($wc, Pod::Item $node, $level) {
    $wc.item(@*TEXT, $node.level // Any);
}

multi sub pw-recurse($wc, Pod::Config $node, $level) {
    $wc.item($node.type, $node.config);
}

multi sub pw-recurse($wc, @olditems, $level) {
    my @newitems;
    @newitems.push(pw-recurse($wc, $_, $level+1)) for @olditems;
    @newitems;
}

# XXX replace with "Stringy $node" when appropriate
multi sub pw-recurse($wc, Str $node, $level) {
    $wc.plain($node);
}