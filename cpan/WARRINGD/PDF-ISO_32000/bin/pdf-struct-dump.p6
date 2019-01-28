#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::Catalog;
use PDF::Content::Graphics;
use PDF::Page;
use PDF::StructTreeRoot;
use PDF::StructElem :StructElemChild;
use PDF::MCR;
use PDF::OBJR;
use PDF::Annot;
use PDF::NumberTree :NumberTree;
use PDF::Font::Loader;
use PDF::Content;
use PDF::IO;

constant StandardTag = PDF::StructTreeRoot::StandardStructureType;
subset Number of Int where { !.defined || $_ > 0 };

my $*class-map;
my StandardTag %*role-map;
my NumberTree $*parent-tree;

sub html-escape(Str $_) {
    .trans:
        /\&/ => '&amp;',
        /\</ => '&lt;',
        /\>/ => '&gt;',
}

sub MAIN(Str $infile,           #= input PDF
	 Str :$password = '',   #= password for the input PDF, if encrypted
         Number :$page,         #= page to dump
         Number :$*max-depth = 10,    #= depth to ascend/descend struct tree
         Str    :$*search-tag,
         Number :$*select,
         UInt   :$obj-num = 0,
         UInt   :$gen-num = 0,
         Bool   :$*render = True,
         Bool   :$*atts = False,
         Bool   :$*debug,
    ) {

    my $input = PDF::IO.coerce(
       $infile eq '-'
           ?? $*IN.slurp-rest( :bin ) # not random access
           !! $infile.IO
    );

    my PDF::Class $pdf .= open( $input, :$password );
    my PDF::Catalog $catalog = $pdf.catalog;
    my PDF::StructTreeRoot $root =  $pdf.catalog.StructTreeRoot
        // die "document does not contain marked content: $infile";

    $*class-map = $_ with $root.ClassMap;
    %*role-map = $_ with $root.RoleMap;
    $*parent-tree = .number-tree with $root.ParentTree;

    with $page {
        warn "*** Adding Page $_ ***"
            if $*debug;
        my PDF::Page $Pg = $pdf.page($_)
            // die "no page number: $_";
        my @plan;
        @plan.push: deref($Pg);
        @plan = search-up(@plan, ($*search-tag // 'Table'), $*max-depth);
        @plan = @plan[$_ - 1] with $*select;
        for @plan -> $p {
            dump-struct($_, :depth(0)) with $p;
        }
    }
    else {
        my $start = $obj-num
            ?? PDF::COS.coerce( $pdf.reader.ind-obj($obj-num, $gen-num).object,
                                PDF::StructElem)
            !! $root;

        dump-struct($start);
    }
}

sub pad(UInt $depth, Str $s = '') { ('  ' x $depth) ~ $s }

multi sub search-up(@plan, $, 1) {
    @plan;
}

multi sub search-up(@plan where .elems < 1, $, $) {
    @plan;
}

multi sub search-up(@plan, $search-tag, $depth) {
    my @parents;
    my @found;
    my %seen;
    for @plan -> $p {
        my $n = $p ~~ List ?? $p.elems !! 1;
        for 0 ..^ $n {
            with $p[$_] {
                with .?structure-type -> $tag {
                    push(@found, $_)
                        if $tag eq $search-tag || %*role-map{$tag} ~~ $search-tag;
                }
                with .?P {
                    push(@parents, $_)
                        unless %seen{.obj-num}++;
                }
            }
        }
    }
    @found || search-up(@parents, $search-tag, $depth - 1);
}

multi sub dump-struct(PDF::StructTreeRoot $root, :$depth = 0) {
    with $root.K -> $k {
        my $elems = $k ~~ List ?? $k.elems !! 1;
        for 0 ..^ $elems {
            my StructElemChild $c = $k[$_];
            dump-struct($c, :$depth);
        }
    }
}

# page tags hashed by MCID
constant Tags = Hash[PDF::Content::Tag];
my Tags %graphics-tags{PDF::Content::Graphics};

class TextDecoder {
    use PDF::Content::Ops :OpCode;
    has Hash @!save;
    has $.current-font;
    my class Cache {
        has %.font;
    }
    has Cache $.cache .= new;
    method current-font { $!current-font[0] }
    method callback{
        sub ($op, *@args) {
            my $method = OpCode($op).key;
            self."$method"(|@args)
                if $method ~~ 'Save'|'Restore'|'SetFont'|'ShowText'|'ShowSpaceText';
        }
    }
    method render($content) {
        my $obj = self.new();
        my &callback = $obj.callback;
        $content.render(:!tidy, :!strict, :&callback);
    }
    method Save()      {
        @!save.push: %( :$!current-font );
    }
    method Restore()   {
        if @!save {
            with @!save.pop {
                $!current-font = .<current-font>;
            }
        }
    }
    method SetFont(Str $font-key, Numeric $font-size) {
        with $*gfx.resource-entry('Font', $font-key) -> $dict {
            $!current-font = $!cache.font{$dict.obj-num} //= PDF::Font::Loader.load-font: :$dict;
        }
        else {
            warn "unable to locate Font in resource dictionary: $font-key";
            $!current-font = PDF::Content::Util::Font.core-font('courier');
        }
    }
    method ShowText($text-encoded) {
        .children.push: $!current-font.decode($text-encoded, :str)
            with $*gfx.open-tags.tail;
    }
    method ShowSpaceText(List $text) {
        with $*gfx.open-tags.tail -> $tag {
            my Str $last := ' ';
            my @chunks = $text.map: {
                when Str {
                    $last := $!current-font.decode($_, :str);
                }
                when $_ <= -100 && !($last ~~ /\s$/) {
                    # assume implicit space
                    ' '
                }
                default { '' }
            }
            $tag.children.push: @chunks.join('');
        }
    }
}

sub graphics-tags($page) {
    return unless $*render;
    %graphics-tags{$page} //= do {
        warn "Page: {.obj-num} {.gen-num} R" given $page;
        my $gfx = TextDecoder.render($page);
        my PDF::Content::Tag % = $gfx.tags(:flat).map({.mcid => $_ }).grep: *.key.defined;
    }
}

sub atts-str(%atts) {
    %atts.pairs.sort.map({ " {.key}=\"{.value}\"" }).join: '';
}

multi sub dump-struct(PDF::StructElem $node, :$tags is copy = %(), :$depth is copy = 0) {
    say pad($depth, "<!-- struct elem {$node.obj-num} {$node.gen-num} R ({$node.WHAT.^name})) -->")
        if $*debug;
    $tags = graphics-tags($_) with $node.Pg;
    my $name = $node.structure-type;
    my $att = do if $*atts {
        my %attributes;
        for $node.attribute-dicts -> $atts {
            %attributes{$_} = $atts{$_}
            for $atts.keys
        }
        unless %attributes {
            for $node.class-map-keys {
                with $*class-map{$_} -> $class {
                    %attributes{$_} = $class{$_}
                    for $class.keys
                }
            }
        }
        with %*role-map{$name} {
            %attributes<class> //= $name;
            $name = $_;
        }
        %attributes<O>:delete;
        atts-str(%attributes);
    }
    else {
        $name = $_
            with %*role-map{$name};
        ''
    }
    $depth++;

    if $depth >= $*max-depth {
        say pad($depth, "<$name$att/> <!-- see {$node.obj-num} {$node.gen-num} R -->");
    }
    else {
        with $node.ActualText {
            say pad($depth, '<!-- actual text -->')
            if $*debug;
            given trim($_) {
                if $_ eq '' {
                    say pad($depth, "<$name$att/>")
                    unless $name eq 'Span';
                }
                else {
                    say pad($depth, $name eq 'Span' ?? $_ !! "<$name$att>{html-escape($_) }</$name>")
                }
            }
        }
        else {
            with $node.K -> $k {
                my $elems = $k ~~ List ?? $k.elems !! 1;
                say pad($depth, "<$name$att>")
                    unless $name eq 'Span';
        
                for 0 ..^ $elems {
                    my StructElemChild $c = $k[$_];
                    dump-struct($c, :$tags, :$depth);
                }

                say pad($depth, "</$name>")
                    unless $name eq 'Span';
            }
            else {
                say pad($depth, "<$name$att/>");
            }
        }
    }
}

multi sub dump-struct(PDF::OBJR $_, :$tags is copy, :$depth!) {
    say pad($depth, "<!-- OBJR {.obj-num} {.gen-num} R -->")
        if $*debug;
    $tags = graphics-tags($_) with .Pg;
    dump-struct(.Obj, :$tags, :$depth);
}

my %deref{Any};
subset StructNode of Hash where PDF::Page|PDF::StructElem;
sub deref(StructNode $_) {
    %deref{$_} //= do with .struct-parent -> $i {
        with $*parent-tree {.[$i + 0]}
    } // $_;
}

multi sub dump-struct(UInt $mcid, :$tags is copy, :$depth!) {
    say pad($depth, "<!-- mcid $mcid -->")
        if $*debug;
    return unless $*render;
    with $tags{$mcid} -> $tag {
        dump-tag($tag, :$depth);
    }
    else {
        warn "unable to resolve marked content $mcid";
    }
}

multi sub dump-struct(PDF::MCR $_, :$tags is copy, :$depth!) {
    return unless $*render;
    say pad($depth, "<!-- MCR {.obj-num} {.gen-num} R -->")
        if $*debug;
    $tags = graphics-tags($_) with .Pg;
    my UInt $mcid := .MCID;
    with .Stm {
        warn "can't handle marked content streams yet";
    }
    else {
        with $tags{$mcid} -> $tag {
            dump-tag($tag, :$depth);
        }
        else {
            warn "unable to resolve marked content $mcid";
        }
    }
}

multi sub dump-struct(StructNode $_ where !(%deref{$_}:exists), |c) {
    dump-struct( deref($_), |c);
}

multi sub dump-struct(PDF::Field $_, :$tags is copy, :$depth!) {
    warn "todo: dump field obj";
}

multi sub dump-struct(PDF::Annot $_, :$tags is copy, :$depth!) {
    warn "todo: dump annot obj";
}

multi sub dump-struct(List $a, :$depth!, |c) {
    say pad($depth, "<!-- struct list {$a.obj-num} {$a.gen-num} R -->")
        if $*debug;
    for $a.keys {
        dump-struct($_, :$depth, |c)
            with $a[$_];
    }
}

multi sub dump-struct($_, :$tags, :$depth) is default {
    die "unknown struct elem of type {.WHAT.^name}";
    say pad($depth, .perl);
}

sub dump-tag(PDF::Content::Tag $tag, :$depth! is copy) {
    # join text strings. discard this, and child marked content tags for now
    my $text = html-escape($tag.children.grep(Str).join: '');
    say pad($depth, $text);
}

=begin pod

=head1 SYNOPSIS

pdf-struct-dump.p6 [options] file.pdf

Options:
   --password   password for an encrypted PDF

=head1 DESCRIPTION

Locates and dumps structure elements from a tagged PDF.

Currently:

  - being used to extract tables from the PDF32000 specification for documentation and checking purposes.

  - produces raw tagged output in an XML/SGMLish format.

Only some PDF files contain tagged PDF. pdf-info.p6 can be
used to check this:

    % pdf-info.p6 my-doc.pdf | grep Tagged:
    Tagged:     yes

=head1 TODO

  - considering both JSON and HTML as targets.

=end pod
