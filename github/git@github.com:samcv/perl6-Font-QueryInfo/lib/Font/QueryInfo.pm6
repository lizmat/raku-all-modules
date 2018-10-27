#!/usr/bin/env perl6
=begin pod
=head1 NAME

Font::QueryInfo — Queries information about fonts, including name,
style, family, foundry, and the character set the font covers.
=head1 DESCRIPTION

Easy to use routines query information about the font and return it in a hash.
The keys are the names of the properties and the values are the property values.

These are the properties that are available:
=begin code
family          String  Font family names
familylang      String  Languages corresponding to each family
style           String  Font style. Overrides weight and slant
stylelang       String  Languages corresponding to each style
fullname        String  Font full names (often includes style)
fullnamelang    String  Languages corresponding to each fullname
slant           Int     Italic, oblique or roman
weight          Int     Light, medium, demibold, bold or black
size            Double  Point size
width           Int     Condensed, normal or expanded
aspect          Double  Stretches glyphs horizontally before hinting
pixelsize       Double  Pixel size
spacing         Int     Proportional, dual-width, monospace or charcell
foundry         String  Font foundry name
antialias       Bool    Whether glyphs can be antialiased
hinting         Bool    Whether the rasterizer should use hinting
hintstyle       Int     Automatic hinting style
verticallayout  Bool    Use vertical layout
autohint        Bool    Use autohinter instead of normal hinter
globaladvance   Bool    Use font global advance data (deprecated)
file            String  The filename holding the font
index           Int     The index of the font within the file
ftface          FT_Face Use the specified FreeType face object
rasterizer      String  Which rasterizer is in use (deprecated)
outline         Bool    Whether the glyphs are outlines
scalable        Bool    Whether glyphs can be scaled
scale           Double  Scale factor for point->pixel conversions
dpi             Double  Target dots per inch
rgba            Int     unknown, rgb, bgr, vrgb, vbgr, none - subpixel geometry
lcdfilter       Int     Type of LCD filter
minspace        Bool    Eliminate leading from line spacing
charset         CharSet Unicode chars encoded by the font
lang            String  List of RFC-3066-style languages this font supports
fontversion     Int     Version number of the font
capability      String  List of layout capabilities in the font
embolden        Bool    Rasterizer should synthetically embolden the font
fontfeatures    String  List of the feature tags in OpenType to be enabled
prgname         String  String  Name of the running program
=end code

Strings return Str, Bool returns Bool's, Int returns Int's, Double's listed
above return Rat's. CharSet returns a List of Range objects. The rest all
return Str. The exception to this is lang, which returns a set of languages
the font supports.

If the property is not defined, it will return a type object of the type which
would normally be returned.

B<Note:> FreeType v2.11.91 or greater is required for the C<charset> property.

=end pod
state (%data, @fields, $fontconfig-version);
if !%data or !@fields or !$fontconfig-version {
    my $cmd =  run('fc-query',  '--version', :out, :err);
    $fontconfig-version = Version.new($cmd.err.slurp(:close)
    .subst(/^\s*'fontconfig version'\s*/, ''));
    $cmd.out.close;
    my @rows = $=pod[0].contents[5].contents.join.lines».split(/\s+/, 3);
    for ^@rows {
        %data{@rows[$_][0]} = %( 'type' => @rows[$_][1], 'description' => @rows[$_][2] );
    }
    @fields = %data.keys;
}
sub font-query-fc-query-version is export { $fontconfig-version }
#| Queries all of the font's properties. If supplied properties it will query all properties except for the ones
#| given.
multi sub font-query-all (IO::Path:D $file, *@except, Bool:D :$suppress-errors = False, Bool:D :$no-fatal = False) is export {
    @except ?? font-query($file, @fields.grep({$_ ne @except.any}), :$suppress-errors, :$no-fatal) !! font-query($file, @fields, :$suppress-errors, :$no-fatal);
}
#| Queries all of the font's properties and accepts a Str for the filename instead of an IO::Path
multi sub font-query-all (Str:D $file, *@except, Bool:D :$suppress-errors = False, Bool:D :$no-fatal = False) is export {
    font-query($file, @except, :$suppress-errors, :$no-fatal);
}
my @special-list = <family style fullname familylang stylelang fullnamelang>;
sub noop { @_ }
sub error-routine (&err-routine, Str:D $message, IO::Path:D $path) {
    &err-routine("$path $message");
}
#| Queries the font for the specified list of properties. Use :suppress-errors to hide all errors and never
#| die or warn (totally silent). Use :no-fatal to warn instead of dying.
#| Accepts an IO::Path object.
multi sub font-query (IO::Path:D $file, *@list, Bool:D :$suppress-errors = False, Bool:D :$no-fatal = False) is export {
    my $error-routine = $suppress-errors ?? &noop !!
                        $no-fatal        ?? &warn !! &die;
    my $warn-routine  = $suppress-errors ?? &noop !! &warn;
    my @wrong-fields = @list.grep({@fields.any ne $_});
    my $delimiter = "␤";
    error-routine($error-routine, "Didn't get any queries", $file) if !@list;
    error-routine($error-routine, "These are not correct queries: {@wrong-fields.join(' ')}", $file) if @wrong-fields;
    my $cmd = run('fc-scan', '--format', @list.map({'%{' ~ $_ ~ '}'}).join($delimiter), $file.absolute, :out, :err);
    my $out = $cmd.out.slurp(:close);
    my $err = $cmd.err.slurp(:close);
    if !$suppress-errors and ($cmd.exitcode != 0 or $err) {
        error-routine($error-routine, "fc-scan error:\n$err", $file);
    }
    my @results = $out.split($delimiter);
    my %hash;
    error-routine($error-routine, "Malformed response. Got wrong number of elements back.", $file) if @results != @list;
    my %special;
    for ^@results -> $elem {
        my $property = @list[$elem];
        %hash{@list[$elem]} = make-data($property, @results[$elem], $file, $warn-routine, :$suppress-errors);
    }
    for <family style fullname> -> $property {
        my $p2 = $property ~ "lang";
        if !%hash{$property} {
            error-routine($warn-routine, "$property missing", $file);
        }
        if !%hash{$p2} {
            error-routine($warn-routine, "$p2 missing", $file);
        }
        next unless %hash{$property} and %hash{$p2};
        my $a = %hash{$property};
        my $b = %hash{"{$property}lang"};
        my %hash2 =  %hash{$p2}.split(',') Z=> %hash{$property}.split(',');
        %hash{$property} = %hash2;
        %hash{$p2}:delete;
    }
    %hash;
}
#| Accepts an string of the font's path.
multi sub font-query (Str:D      $file, *@list, Bool:D :$suppress-errors = False, Bool:D :$no-fatal = False) is export {
    font-query($file.IO, @list, :$suppress-errors, :$no-fatal);
}
sub make-data (Str:D $property, Str $value, IO::Path $file, $warn-routine, Bool:D :$suppress-errors = False) {
    given %data{$property}<type> {
        when 'Bool' {
            if $value {
                $value eq 'True' ?? True !! $value eq 'False' ?? False !! do {
                    error-routine($warn-routine, "Property $property, expected True or False but got '$value' Leaving as a string", $file)
                        unless $suppress-errors;
                    return $value;
                }
            }
            else {
                return Bool;
            }
        }
        when 'Int' {
            if $value.defined {
                return $value.Int;
            }
            else {
                return Int;
            }
        }
        when 'Double' {
            if $value.defined {
                return $value.Rat;
            }
            else {
                return Rat;
            }
        }
        when 'CharSet' {
            if $fontconfig-version < v2.11.91 {
                error-routine($warn-routine, "fc-query v2.11.91 required for charset", $file);
                return List;
            }
            return $value
                ?? $value.split(' ').map({my @t = .split('-')».parse-base(16); @t > 1 ?? Range.new(@t[0], @t[1]) !! Range.new(@t[0], @t[0]) }).list
                !! List
        }
        default {
            if $property eq 'lang' {
                return $value ?? $value.split('|').Set !! Set;
            }
            return $value ?? $value !! Str;
        }
    }
    Nil;
}
=begin pod

=head1 AUTHOR

Samantha McVey <samantham@posteo.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Samantha McVey

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod