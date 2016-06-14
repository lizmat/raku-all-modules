#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simple::App;
use GTK::Scintilla;
use GTK::Scintilla::Editor;

my $app = GTK::Simple::App.new(title => "Hello GTK + Scintilla!");

my $editor = GTK::Scintilla::Editor.new;
$editor.size-request(500, 300);
$app.set-content($editor);

$editor.style-clear-all;
$editor.set-lexer(SCLEX_PERL);
$editor.style-set-foreground(SCE_PL_COMMENTLINE, 0x008000);
$editor.style-set-foreground(SCE_PL_POD,         0x008000);
$editor.style-set-foreground(SCE_PL_NUMBER,      0x808000);
$editor.style-set-foreground(SCE_PL_WORD,        0x800000);
$editor.style-set-foreground(SCE_PL_STRING,      0x800080);
$editor.style-set-foreground(SCE_PL_OPERATOR, 1);
$editor.insert-text(0, q{
# A Perl comment
use Modern::Perl;

say "Hello world";
});

$editor.show;
$app.run;
