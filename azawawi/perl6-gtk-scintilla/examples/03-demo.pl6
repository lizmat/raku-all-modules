#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simple::App;
use GTK::Simple::Menu;
use GTK::Simple::MenuBar;
use GTK::Simple::MenuItem;
use GTK::Simple::MenuToolButton;
use GTK::Simple::Toolbar;
use GTK::Simple::VBox;
use GTK::Scintilla;
use GTK::Scintilla::Editor;

sub MAIN() {
    my $app = GTK::Simple::App.new( title => "GTK::Scintilla Demo" );

    my $toolbar-vbox  = add-toolbar($app);
    my $menu-bar-vbox = add-menu-bar($app);
    my $editor        = add-editor($app);
    $app.set-content(
        GTK::Simple::VBox.new([
            { :widget($menu-bar-vbox), :expand(False) },
            { :widget($toolbar-vbox),  :expand(False) },
            $editor
        ])
    );
    $app.show-all;
    $app.run;
}

sub add-editor($app) {
    my $editor = GTK::Scintilla::Editor.new;

    $editor.style-clear-all;
    $editor.lexer(SCLEX_PERL);
    $editor.style-foreground(SCE_PL_COMMENTLINE, 0x008000);
    $editor.style-foreground(SCE_PL_POD,         0x008000);
    $editor.style-foreground(SCE_PL_NUMBER,      0x808000);
    $editor.style-foreground(SCE_PL_WORD,        0x800000);
    $editor.style-foreground(SCE_PL_STRING,      0x800080);
    $editor.style-foreground(SCE_PL_OPERATOR,    1);
    $editor.text(q{
# A Perl comment
use Modern::Perl;

say "Hello world";
});

    $editor;
}

sub add-menu-bar($app) {
    my $file-menu-item = GTK::Simple::MenuItem.new( :label("File") );
    $file-menu-item.set-sub-menu(
        my $file-menu = GTK::Simple::Menu.new
    );

    my $quit-menu-item = GTK::Simple::MenuItem.new( :label("Quit") );
    $file-menu.append($quit-menu-item);

    my $menu-bar = GTK::Simple::MenuBar.new;
    $menu-bar.append($file-menu-item);

    $quit-menu-item.activate.tap: {
        $app.exit;
    }

    $menu-bar.pack;
}

sub add-toolbar($app) {
    my $toolbar = GTK::Simple::Toolbar.new;
    $toolbar.add-menu-item(
        my $new-toolbar-button = GTK::Simple::MenuToolButton.new(
            :icon(GTK_STOCK_NEW)
        )
    );
    $toolbar.add-menu-item(
        my $open-toolbar-button = GTK::Simple::MenuToolButton.new(
            :icon(GTK_STOCK_OPEN)
        )
    );
    $toolbar.add-menu-item(
        my $save-toolbar-button = GTK::Simple::MenuToolButton.new(
            :icon(GTK_STOCK_SAVE)
        )
    );
    $toolbar.add-separator;
    $toolbar.add-menu-item(
        my $exit-toolbar-button = GTK::Simple::MenuToolButton.new(
            :icon(GTK_STOCK_QUIT)
        )
    );

    $new-toolbar-button.clicked.tap: {
        "New toolbar button clicked".say;
    }
    $open-toolbar-button.clicked.tap: {
        "Open toolbar button clicked".say;
    }
    $save-toolbar-button.clicked.tap: {
        "Save toolbar button clicked".say;
    }
    $exit-toolbar-button.clicked.tap: {
        $app.exit;
    }

    $toolbar.pack;
}
