![gtk logo][logo]

# GTK::V3 - Accessing Gtk version 3.*
<!--
[![Build Status](https://travis-ci.org/MARTIMM/gtk-glade.svg?branch=master)](https://travis-ci.org/MARTIMM/gtk-glade) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/6yaqqq9lgbq6nqot?svg=true&branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending)](https://ci.appveyor.com/project/MARTIMM/gtk-glade/branch/master)
-->
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

I would like to thank the developers of the GTK::Simple project because of the information I got while reading the code. Also because one of the files is copied unaltered for which I did not had to think about to get that right.

# Description

# Synopsis

# Motivation
I perhaps should have used parts of `GTK::Simple` but I wanted to study the native call interface which I am now encountering more seriously. Therefore I started a new project with likewise objects as can be found in `GTK::Simple`.

The other reason I want to start a new project is that after some time working with the native call interface. I came to the conclusion that Perl6 is not yet capable to return a proper message when mistakes are made by me e.g. spelling errors or using wrong types. Most of them end up in **MoarVM panic: Internal error: Unwound entire stack and missed handler**. Other times it ends in just a plain crash. I am very confident that this will be improved later but for the time being I had to improve the maintainability of this project by hiding the native stuff as much as possible. Although the error messages may be improved, some of the crashes are happening within GTK and cannot be captured by Perl6. One of those moments are the use of GTK calls without initializing GTK with `gtk_init`. This can also be covered by setting an init-flag which should be checked by almost every other module. The panic mentioned above mostly happens when perl6 code is called from C as a callback. The stack might not be interpreted completely at that moment.

There are some points I noticed in the `GTK::Simple` modules.
* The `GTK::Simple::Raw` module where all the native subs are defined is quite large. Only a few subs can be found elsewhere. The file is also growing with each additional declaration. Using that module is always a parsing impact despite the several import selection switches one can use.
* I would like to follow the GTK interface more closely when it comes to the native subs. What I want therefore is a class per gtk include file as much as possible. For example, there is this file `gtklabel.h` for which I would like to make the class `GtkLabel` in perl6. In a similar module in `GTK::Simple` named `Label`, there is a `text` method while I want to have `gtk_label_get_text` and `gtk_label_set_text` modules as in the [documentation of GTK][gtklabel] is specified. This makes it more legitimate to just refer to the GTK documentation instead of having my own docs.
<!--
* There is no inheritance in `GTK::Simple`. A kind of a central role is made which most widget classes use. I would like to have inheritance where for example `GtkLabel` inherits from `GtkWidget`. Then the methods from `GtkWidget` will also be available in `GtkLabel`.
* I want the native subs out of reach of the user. So the `is export` trait is removed. This is important to prevent LTA messages mentioned above.
-->
<!--
* When callbacks are defined in GTK, they can accept most of the time some user data to do something with it in the callback. GTK::Simple gives them the OpaquePointer type which renders them useless. Most of the time small Routines are used in place of the handler entry. The code used there can close over the variables you want to use and in that situation there is no problem. This changes when the Routines are defined in a separate sub because of the length or complexity of the code. The data can only be handed over to the Routine using the call interface. What type should I take then. I found out that all kinds can be used so I decided to take `CArray[Str]` to have the most flexible choice.
-->
* Next thought of mine is wrong: **Define original `g_signal_connect_object` function instead of changing the name into `g_signal_connect_wd`.** The problem is that in Perl6 the handlers signature is fixed when defining a callback for signals and that there are several types of callbacks possible in GTK widgets. Most of the handlers are having the same signature for a handler. E.g. a `clicked` event handler receives a widget and data. That's why the sub is called like that: `g_signal_connect_wd`. There are other signals using a different signature such as the gtk container `add` event. That one has 2 widgets and then data. So I added `g_signal_connect_wwd` to handle that one. Similar setups may follow.

These arguments will present some problems
* How to store the native widget. This is a central object representing the widget for the class wherein it is created. It is used where widgets like labels, dialogs, frames, listboxes etc are used. Because it is just a pointer to a C object we do not need to build inheritance around this. Like in `GTK::Simple` I used a role for that, only not named after a GTK like class.
* Do I have to write a method for each native sub introduced? Fortunately, that is not necessary. I used the **FALLBACK** mechanism for that. When not found, the search is handed over to the parent. In this process it is possible to accept other names as well which end up finding the same native sub. To let this mechanism work the `FALLBACK` method is defined in the role module. This method will then call the method `fallback` in the modules using the role. When nothing found, `fallback` must call the parents fallback with `callsame`. The subs in some classes all start with some prefix which can be left out too, provided that the fallback functions also test with an added prefix. So e.g. a sub `gtk_label_get_text` defined in class `GtkLabel` can be called like `$label.gtk_label_get_text()` or `$label.get_text()`. As an extra feature dashes can be used instead of underscores, so `$label.gtk-label-get-text()` or `$label.get-text()` works too.
* Is the sub accessible when removing the `is export` trait? No, not directly but because the `fallback` method will search in their own name space, they can get hold of the sub reference which is returned to the callers `FALLBACK`. The call then is made with the given arguments prefixed with the native widgets address stored in the role. This way the native call is shielded off and perl6 is able to return proper messages when mistakes are made in spelling or type mismatches.
* Not all calls have the widget on their first argument. That is solved by investigating the subroutines signature of which the first argument is a N-GObject or not.

Not all of the GTK, GDK or Glib subroutines from the libraries will be covered because not everything is needed. Other reasons are that classes and many subs are deprecated. This package will support the 3.* version of GTK. There is already a 4.* version out but that is food for later thoughts. The root of the library will be GTK::V3 and can be separated later into a another package.

# Documentation

## Gtk library

* GTK::V3::Gtk::GtkAboutDialog at [Gnome developer][gtkaboutdialog] and [V3 pod doc](doc/GtkAboutDialog.html)

* [GTK::V3::Gtk::GtkBin][gtkbin] is **GTK::V3::Gtk::GtkContainer**
  * `[gtk_bin_]get_child ( --> N-GObject )`

* [GTK::V3::Gtk::GtkBuilder][gtkbuilder] is **GTK::V3::Glib::GObject**
  * `new ( Bool :$empty )`
  * `new ( Str:D :$filename )`
  * `new ( Str:D :$string )`
  * `add-gui ( Str:D :$filename! )`
  * `add-gui ( Str:D :$string! )`
  * `gtk_builder_new ( --> N-GObject )` [6]
  * `[gtk_builder_]new_from_file ( Str $glade-ui --> N-GObject )`
  * `[gtk_builder_]new_from_string ( Str $glade-ui, uint32 $length --> N-GObject )`
  * `[gtk_builder_]add_from_file( Str $glade-ui, OpaquePointer $error --> int32 )`
  * `[gtk_builder_]add_from_string ( Str $glade-ui, uint32 $size, OpaquePointer $error --> int32 )`
  * `[gtk_builder_]get_object ( Str $object-id --> N-GObject )`
  * `[gtk_builder_]get_type_from_name ( Str $type_name --> int32 )`

* [GTK::V3::Gtk::GtkButton][gtkbutton] is **GTK::V3::Gtk::GtkBin**
  * `new ( Str :$empty )`
  * `new ( Str :$label )`
  * `gtk_button_new ( --> N-GObject )`
  * `[gtk_button_]new_with_label ( Str $label --> N-GObject )`
  * `[gtk_button_]get_label ( --> Str )`
  * `[gtk_button_]set_label ( Str $label )`

* [GTK::V3::Gtk::GtkCheckButton][gtkcheckbutton] is **GTK::V3::Gtk::GtkToggleButton**
  * `new ( Str :$empty )`
  * `new ( Str :$label )`
  * `gtk_toggle_button_new ( --> N-GObject )`
  * `[gtk_toggle_button_]new_with_label ( Str $label --> N-GObject )`
  * `[gtk_toggle_button_]get_active ( --> int32 )`
  * `[gtk_toggle_button_]set_active ( int32 $active )`

* [GTK::V3::Gtk::GtkContainer][gtkcontainer] is **GTK::V3::Gtk::GtkWidget**
  * `gtk_container_add ( N-GObject $widget )` [9]
  * `gtk_container_get_border_width ( --> int32 )`
  * `gtk_container_get_children ( --> N-GList )`
  * `gtk_container_set_border_width ( int32 $border_width )`

* [GTK::V3::Gtk::GtkCssProvider][gtkcssprovider] is **GTK::V3::Glib::GObject**
  * `gtk_css_provider_new ( --> N-GObject )`
  * `[gtk_css_provider_]get_named ( Str $name, Str $variant --> N-GObject )`
  * `[gtk_css_provider_]load_from_path ( Str $css-file, OpaquePointer)`

* [GTK::V3::Gtk::GtkStyleContext][gtkstylecontext] is **GTK::V3::Glib::GObject**

  * `[gtk_style_context_]add_provider_for_screen ( N-GObject $screen, int32 $provider, int32 $priority )`

* [GTK::V3::Gtk::GtkDialog][gtkdialog] is **GTK::V3::Gtk::GtkWindow**

* [GTK::V3::Gtk::GtkEntry][gtkentry] is **GTK::V3::Gtk::GtkWidget**

* [GTK::V3::Gtk::GtkGrid][gtkgrid] is **GTK::V3::Gtk::GtkContainer**
  * `new ( )`
  <!--* `new ( N-GObject $grid )`-->
  * `gtk_grid_attach ( N-GObject $child, Int $x, Int $y, Int $w, Int $h)`
  * `gtk_grid_insert_row ( Int $position )`
  * `gtk_grid_insert_column ( Int $position )`
  * `gtk_grid_get_child_at ( UInt $left, UInt $top --> N-GObject )`
  * `gtk_grid_set_row_spacing ( UInt $spacing )`

* [GTK::V3::Gtk::GtkImage][gtkimage] is **GTK::V3::Gtk::GtkWidget**

* [GTK::V3::Gtk::GtkImageMenuItem][gtkimagemenuitem] is **GTK::V3::Gtk::GtkMenuItem**

* [GTK::V3::Gtk::GtkLabel][gtklabel] is **GTK::V3::Gtk::GtkWidget**
  * `new ( Str :$text? )`
  <!--* `new ( N-GObject $grid )`-->
  * `gtk_label_get_text ( --> Str )`
  * `gtk_label_set_text ( Str $str )`

* [GTK::V3::Gtk::GtkListBox][gtklistbox] is **GTK::V3::Gtk::GtkContainer**

* [GTK::V3::Gtk::GtkMain][gtkmain]

* [GTK::V3::Gtk::GtkMenuItem][gtkmenuitem] is **GTK::V3::Gtk::GtkBin**

* [GTK::V3::Gtk::GtkRadioButton][gtkradiobutton] is **GTK::V3::Gtk::GtkCheckbutton**

* [GTK::V3::Gtk::GtkTextBuffer][gtktextbuffer] is **GTK::V3::Glib::GObject**

* [GTK::V3::Gtk::GtkTextTagTable][gtktexttagtable] is **GTK::V3::Glib::GObject**

* [GTK::V3::Gtk::GtkTextView][gtktextview] is **GTK::V3::Gtk::GtkContainer**

* [GTK::V3::Gtk::GtkToggleButton][gtktogglebutton] is **GTK::V3::Gtk::GtkButton**

* [GTK::V3::Gtk::GtkWidget][gtkwidget] is **GTK::V3::Glib::GInitiallyUnowned**

* [GTK::V3::Gtk::GtkWindow][gtkwindow] is **GTK::V3::Gtk::GtkBin**

## Gdk library

* GTK::V3::Gdk::GdkDisplay is **GTK::V3::Glib::GObject**

* GTK::V3::Gdk::GdkScreen is **GTK::V3::Glib::GObject**

* GTK::V3::Gdk::GdkWindow is **GTK::V3::Glib::GObject**

## Glib library

<!-- * [GTK::V3::Glib::GError][gerror] -->

* GTK::V3::Glib::GInitiallyUnowned is **GTK::V3::Glib::GObject**

* [GTK::V3::Glib::GList][glist]

* [GTK::V3::Glib::GSList][gslist]

* [GTK::V3::Glib::GMain][gmain]

* [GTK::V3::Glib::GObject][gobject]
  * `class N-GObject`
  * `CALL-ME ( N-GObject $widget? --> N-GObject )` [1]
  * `FALLBACK ( $native-sub, |c )` [2]
  * `new ( N-GObject :$widget )` [7]
  * `new ( Str :$build-id )` [8]
  * `native-gobject ( N-GObject $widget )`

* [GTK::V3::Glib::GType][gtype]
  * `[g_type_]name ( int32 $type --> Str )`
  * `[g_type_]from_name ( Str --> int32 )`
  * `[g_type_]parent ( int32 $type --> int32 )`
  * `[g_type_]depth ( int32 $type --> uint32 )`

## Miscellaneous

* class **X::GTK::V3** (use GTK::V3::X) is **Exception**
  * `test-catch-exception ( Exception $e, Str $native-sub )`
  * `test-call ( $handler, $gobject, |c )`

### Notes
  1) The `CALL-ME` method is coded in such a way that a native widget can be set or retrieved easily. E.g.
      ```
      my GTK::V3::Gtk::GtkLabel $label .= new(:label('my label'));
      my GTK::V3::Gtk::GtkGrid $grid .= new;
      $grid.gtk_grid_attach( $label(), 0, 0, 1, 1);
      ```
      Notice how the native widget is retrieved with `$label()`.
  2) The `FALLBACK` method is used to test for the defined native functions as if the functions where methods. It calls the `fallback` methods in the class which in turn call the parent fallback using `callsame`. The resulting function addres is returned and processed with the `test-call` functions from **GTK::V3::X**. Thrown exceptions are handled by the function `test-catch-exception` from the same module.
  3) `N-GObject` is a native widget which is held internally in most of the classes. Sometimes they need to be handed over in a call or stored when it is returned.
  4) Each method can at least be called with perl6 like dashes in the method name. E.g. `gtk_container_add` can be written as `gtk-container-add`.
  5) In some cases the calls can be shortened too. E.g. `gtk_button_get_label` can also be called like `get_label` or `get-label`. Sometimes, when shortened, calls can end up with a call using the wrong native widget. When in doubt use the complete method call.
  6) Also a sub like `gtk_button_new` cannot be shortened because it will call the perl6 init method `new()`. In most cases, these calls are used when initializing classes, in this case to initialize a `GTK::V3::Gtk::GtkButton` class. Above brackets '[]' show which part can be chopped.
  7) All classes deriving from GtkObject know about the `:widget` named attribute when instantiating a widget class. This is used when the result of another native sub returns a N-GObject. This option works for all child classes too. E.g. cleaning a list box;
    ```
    my GTK::V3::Gtk::GtkListBox $list-box .= new(:build-id<someListBox>);
    loop {
      # Keep the index 0, entries will shift up after removal
      my $nw = $list-box.get-row-at-index(0);
      last unless $nw.defined;
      my GTK::V3::Gtk::GtkBin $lb-row .= new(:widget($nw));
      $lb-row.gtk-widget-destroy;
    }
    ```
  8) The attribute `:build-id` is used when a N-GObject is returned from builder for a search with a given object id using `$builder.gtk_builder_get_object()`. A builder must be initialized before to be useful. This option works for all child classes too. E.g.
    ```
    my GTK::V3::Gtk::GtkLabel $label .= new(:build-id<inputLabel>);
    ```
  9) Sometimes a `N-GObject` must be given as a parameter. As mentioned above in [1] the CALL-ME method helps to return that object. To prevent mistakes (forgetting the '()' after the object), the parameters to the call are checked for the use of a GtkObject instead of the native object. When encountered, the parameters are automatically converted. E.g.
    ```
    my GTK::V3::Gtk::GtkButton $button .= new(:label('press here'));
    my GTK::V3::Gtk::GtkLabel $label .= new(:label('note'));

    my GTK::V3::Gtk::GtkGrid $grid .= new(:empty);
    $grid.attach( $button, 0, 0, 1, 1);
    $grid.attach( $label, 0, 1, 1, 1);
    ```
    Here in the call to gtk_grid_attach $button and $label is used instead of $button() and label().

## Miscellaneous
* [Release notes][release]

# TODO

# Versions of involved software

* Program is tested against the latest version of **perl6** on **rakudo** en **moarvm**.
* Generated user interface file is for **Gtk >= 3.10**


# Installation of GTK::V3

`zef install GTK::V3`


# Author

Name: **Marcel Timmerman**
Github account name: Github account MARTIMM


<!---- [refs] ----------------------------------------------------------------->
[release]: https://github.com/MARTIMM/gtk-glade/blob/master/doc/CHANGES.md
[logo]: doc/gtk-logo-100.png

[gtkbin]: https://developer.gnome.org/gtk3/stable/GtkBin.html
[gtkbuilder]: https://developer.gnome.org/gtk3/stable/GtkBuilder.html
[gtkbutton]: https://developer.gnome.org/gtk3/stable/GtkButton.html
[gtktogglebutton]: https://developer.gnome.org/gtk3/stable/GtkToggleButton.html
[gtkcheckbutton]: https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
[gtkcontainer]: https://developer.gnome.org/gtk3/stable/GtkContainer.html
[gtkgrid]: https://developer.gnome.org/gtk3/stable/GtkGrid.html
[gtklabel]: https://developer.gnome.org/gtk3/stable/GtkLabel.html
[gtkcssprovider]: https://developer.gnome.org/gtk3/stable/GtkCssProvider.html
[gtkdialog]: https://developer.gnome.org/gtk3/stable/GtkDialog.html
[gtkentry]: https://developer.gnome.org/gtk3/stable/GtkEntry.html
[gtkimage]: https://developer.gnome.org/gtk3/stable/GtkImage.html
[gtkimagemenuitem]: https://developer.gnome.org/gtk3/stable/GtkImageMenuItem.html
[gtkmain]: https://developer.gnome.org/gtk3/stable/GtkMain.html
[gtkwidget]: https://developer.gnome.org/gtk3/stable/GtkWidget.html
[gtktextbuffer]: https://developer.gnome.org/gtk3/stable/GtkTextBuffer.html
[gtkmenuitem]: https://developer.gnome.org/gtk3/stable/GtkMenuItem.html
[gtktexttagtable]: https://developer.gnome.org/gtk3/stable/GtkTextTagTable.html
[gtktextview]: https://developer.gnome.org/gtk3/stable/GtkTextView.html
[gtktogglebutton]: https://developer.gnome.org/gtk3/stable/GtkToggleButton.html
[gtkwindow]: https://developer.gnome.org/gtk3/stable/GtkWindow.html
[gtkaboutdialog]: https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html

[gtkradiobutton]: https://developer.gnome.org/gtk3/stable/GtkRadioButton.html

[gerror]:
[gmain]:
[gobject]:
[gtype]:
[glist]:
[gslist]:

<!--
[todo]: https://github.com/MARTIMM/Library/blob/master/doc/TODO.md
[man]: https://github.com/MARTIMM/Library/blob/master/doc/manual.pdf
[requir]: https://github.com/MARTIMM/Library/blob/master/doc/requirements.pdf
-->
