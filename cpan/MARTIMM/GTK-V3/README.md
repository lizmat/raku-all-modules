![gtk logo][logo]

# GTK::V3 - Accessing Gtk version 3.*
<!--
[![Build Status](https://travis-ci.org/MARTIMM/gtk-glade.svg?branch=master)](https://travis-ci.org/MARTIMM/gtk-glade) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/6yaqqq9lgbq6nqot?svg=true&branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending)](https://ci.appveyor.com/project/MARTIMM/gtk-glade/branch/master)
-->
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description
First of all, I would like to thank the developers of the GTK::Simple project because of the information I got while reading the code. Also because one of the files is copied unaltered for which I did not had to think about to get that right.

The purpose of this project is to create an interface to the **GTK** version 3 library. Previously I had this library in GTK::Glade but because of its growth I decided to create a separate project.

I want to follow the interface of Gtk, Gdk and Glib as closely as possible by keeping the names of the native functions the same as provided with the following exceptions;
* The native subroutines are defined in their classes. They are setup in such a way that they have become methods in those classes. Many subs also have as their first argument a the native object. This object is held in the class and is automatically inserted when needed. E.g. a definition like the following in the GtkButton class
  ```
  sub gtk_button_set_label ( N-GObject $widget, Str $label )
    is native(&gtk-lib)
    { * }
  ```
  can be used as
  ```
  my GTK::V3::Gtk::GtkButton $button .= new(:empty);
  $button.gtk_button_set_label('Start Program');
  ```

* The names are sometimes long and prefixed with words which are used in the class name. Therefore, those names can be shortened by removing those prefixes. An example method in the `GtkButton` class is `gtk_button_get_label()`. This can be shortened to `get_label()`.
  ```
  my GTK::V3::Gtk::GtkButton $button .= new(:label<Stop>);
  my Str $button-label = $button.get_label;
  ```

* Names can not be shortened too much. E.g. `gtk_button_new` and `gtk_label_new` yield `new` which is a perl method from class `Mu`. I am thinking about chopping off the `g_`, `gdk_` and `gtk_` prefixes.

* All the method names are written with an underscore. Following a perl6 tradition; dashed versions is also possible.
  ```
  my Str $button-label = $button.gtk-button-get-label;
  ```

* Sometimes I had to stray away from the native function names because of the way one has define it in perl6. This is caused by the possibility of returning or specifying different types of values depending on how the function is used. E.g. `g_slist_nth_data()` can return several types of data. This had to be solved like here which yields the methods `g_slist_nth_data_str` and `g_slist_nth_data_gobject`.

  ```
  sub g_slist_nth_data_str ( N-GSList $list, uint32 $n --> Str )
    is native(&gtk-lib)
    is symbol('g_slist_nth_data')
    { * }

  sub g_slist_nth_data_gobject ( N-GSList $list, uint32 $n --> N-GObject )
    is native(&gtk-lib)
    is symbol('g_slist_nth_data')
    { * }
  ```

* Not all native subs or even classes will be implemented or implemented much later because of the following reasons;
  * Many subs and some classes are obsolete.
  * The original idea was to have the interface build by the glade interface designer. This lib was in the GTK::Glade project before re-factoring. Therefor a GtkButton does not have to have all subs to create a button. On the other hand a GtkListBox is a widget which is changed dynamically and therefore need more subs to manipulate the widget and its contents.
  * The need to implement classes like GtkAssistant, GtkAlignment or GtkScrolledWindow is on a low priority because these can all be instantiated by `GtkBuilder` using your Glade design.

# Motivation
I perhaps should have used parts of `GTK::Simple` but I wanted to study the native call interface which I am now encountering more seriously. Therefore I started a new project with likewise objects as can be found in `GTK::Simple`.

The other reason I want to start a new project is that after some time working with the native call interface. I came to the conclusion that Perl6 is not yet capable to return a proper message when mistakes are made by me e.g. spelling errors or using wrong types. Most of them end up in **MoarVM panic: Internal error: Unwound entire stack and missed handler**. Other times it ends in just a plain crash. I am very confident that this will be improved later but for the time being I had to improve the maintainability of this project by hiding the native stuff as much as possible. Although the error messages may be improved, some of the crashes are happening within GTK and cannot be captured by Perl6. One of those moments are the use of GTK calls without initializing GTK with `gtk_init`. This is solved by using an initialization flag which is checked in the `GtkMain` module. The module is referred to by `GObject` which almost all modules inherit from.

The panic mentioned above mostly happens when perl6 code is called from C as a callback. The stack might not be interpreted completely at that moment hence the message.

<!--
There are some points I noticed in the `GTK::Simple` modules.
* The `GTK::Simple::Raw` module where all the native subs are defined is quite large. Only a few subs can be found elsewhere. The file is also growing with each additional declaration. Using that module is always a parsing impact despite the several import selection switches one can use.
* I would like to follow the GTK interface more closely when it comes to the native subs. What I want therefore is a class per gtk include file as much as possible. For example, there is this file `gtklabel.h` for which I would like to make the class `GtkLabel` in perl6. In a similar module in `GTK::Simple` named `Label`, there is a `text` method while I want to have `gtk_label_get_text` and `gtk_label_set_text` modules as in the [documentation of GTK][gtklabel] is specified. This makes it more legitimate to just refer to the GTK documentation instead of having my own docs.

* There is no inheritance in `GTK::Simple`. A kind of a central role is made which most widget classes use. I would like to have inheritance where for example `GtkLabel` inherits from `GtkWidget`. Then the methods from `GtkWidget` will also be available in `GtkLabel`.
* I want the native subs out of reach of the user. So the `is export` trait is removed. This is important to prevent LTA messages mentioned above.
-->
<!--
* When callbacks are defined in GTK, they can accept most of the time some user data to do something with it in the callback. GTK::Simple gives them the OpaquePointer type which renders them useless. Most of the time small Routines are used in place of the handler entry. The code used there can close over the variables you want to use and in that situation there is no problem. This changes when the Routines are defined in a separate sub because of the length or complexity of the code. The data can only be handed over to the Routine using the call interface. What type should I take then. I found out that all kinds can be used so I decided to take `CArray[Str]` to have the most flexible choice.

* Next thought of mine is wrong: **Define original `g_signal_connect_object` function instead of changing the name into `g_signal_connect_wd`.** The problem is that in Perl6 the handlers signature is fixed when defining a callback for signals and that there are several types of callbacks possible in GTK widgets. Most of the handlers are having the same signature for a handler. E.g. a `clicked` event handler receives a widget and data. That's why the sub is called like that: `g_signal_connect_wd`. There are other signals using a different signature such as the gtk container `add` event. That one has 2 widgets and then data. So I added `g_signal_connect_wwd` to handle that one. Similar setups may follow.

These arguments will present some problems
* How to store the native widget. This is a central object representing the widget for the class wherein it is created. It is used where widgets like labels, dialogs, frames, listboxes etc are used. Because it is just a pointer to a C object we do not need to build inheritance around this. Like in `GTK::Simple` I used a role for that, only not named after a GTK like class.
* Do I have to write a method for each native sub introduced? Fortunately, that is not necessary. I used the **FALLBACK** mechanism for that. When not found, the search is handed over to the parent. In this process it is possible to accept other names as well which end up finding the same native sub. To let this mechanism work the `FALLBACK` method is defined in the role module. This method will then call the method `fallback` in the modules using the role. When nothing found, `fallback` must call the parents fallback with `callsame`. The subs in some classes all start with some prefix which can be left out too, provided that the fallback functions also test with an added prefix. So e.g. a sub `gtk_label_get_text` defined in class `GtkLabel` can be called like `$label.gtk_label_get_text()` or `$label.get_text()`. As an extra feature dashes can be used instead of underscores, so `$label.gtk-label-get-text()` or `$label.get-text()` works too.
* Is the sub accessible when removing the `is export` trait? No, not directly but because the `fallback` method will search in their own name space, they can get hold of the sub reference which is returned to the callers `FALLBACK`. The call then is made with the given arguments prefixed with the native widgets address stored in the role. This way the native call is shielded off and perl6 is able to return proper messages when mistakes are made in spelling or type mismatches.
* Not all calls have the widget on their first argument. That is solved by investigating the subroutines signature of which the first argument is a N-GObject or not.

Not all of the GTK, GDK or Glib subroutines from the libraries will be covered because not everything is needed. Other reasons are that classes and many subs are deprecated. This package will support the 3.* version of GTK. There is already a 4.* version out but that is food for later thoughts. The root of the library will be GTK::V3 and can be separated later into a another package.
-->

# Synopsis

# Documentation

## Gtk library

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|-------------------------|
| [GTK::V3::Gtk::GtkAboutDialog](doc/GtkAboutDialog.pdf) | [GtkAboutDialog.html][gtkaboutdialog]
| [GTK::V3::Gtk::GtkBin](doc/GtkBin.pdf) | [GtkBin.html][gtkbin]
| GTK::V3::Gtk::GtkBuilder |  [GtkBuilder.html][gtkbuilder]
| GTK::V3::Gtk::GtkButton |  [GtkButton.html][gtkbutton]
| GTK::V3::Gtk::GtkCheckButton |  [GtkCheckButton.html][gtkcheckbutton]
| GTK::V3::Gtk::GtkContainer |  [GtkContainer.html][gtkcontainer]
| GTK::V3::Gtk::GtkCssProvider |  [GtkCssProvider.html][gtkcssprovider]
| GTK::V3::Gtk::GtkStyleContext |  [GtkStyleContext.html][gtkstylecontext]
| GTK::V3::Gtk::GtkDialog |  [GtkDialog.html][gtkdialog]
| GTK::V3::Gtk::GtkEntry |  [GtkEntry.html][gtkentry]
| GTK::V3::Gtk::GtkFileChooser |  [GtkFileChooser.html][GtkFileChooser]
| [GTK::V3::Gtk::GtkFileChooserDialog](doc/GtkFileChooserDialog.pdf) |  [GtkFileChooserDialog.html][GtkFileChooserDialog]
| GTK::V3::Gtk::GtkFileFilter |  [GtkFileFilter.html][GtkFileFilter]
| GTK::V3::Gtk::GtkGrid |  [GtkGrid.html][gtkgrid]
| GTK::V3::Gtk::GtkImage |  [GtkImage.html][gtkimage]
| GTK::V3::Gtk::GtkImageMenuItem |  [GtkImageMenuItem.html][gtkimagemenuitem]
| GTK::V3::Gtk::GtkLabel |  [GtkLabel.html][gtklabel]
| GTK::V3::Gtk::GtkListBox |  [GtkListBox.html][gtklistbox]
| GTK::V3::Gtk::GtkMain |  [GtkMain.html][gtkmain]
| GTK::V3::Gtk::GtkMenuItem |  [GtkMenuItem.html][gtkmenuitem]
| GTK::V3::Gtk::GtkRadioButton |  [GtkRadioButton.html][gtkradiobutton]
| GTK::V3::Gtk::GtkStyleContext |  [GtkStyleContext.html][GtkStyleContext]
| GTK::V3::Gtk::GtkTextBuffer |  [GtkTextBuffer.html][gtktextbuffer]
| GTK::V3::Gtk::GtkTextTagTable |  [GtkTextTagTable.html][gtktexttagtable] |
| GTK::V3::Gtk::GtkTextView |  [GtkTextView.html][gtktextview]
| GTK::V3::Gtk::GtkToggleButton |  [GtkToggleButton.html][gtktogglebutton]
| GTK::V3::Gtk::GtkWidget |  [GtkWidget.html][gtkwidget]
| GTK::V3::Gtk::GtkWindow |  [GtkWindow.html][gtkwindow]

## Gdk library

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|-------------------------|
| GTK::V3::Gdk::GdkDisplay |  [Controls a set of GdkScreens and their associated input devices][GdkDisplay]
| GTK::V3::Gdk::GdkScreen |  [Object representing a physical screen][GdkScreen]
| GTK::V3::Gdk::GdkTypes |
| GTK::V3::Gdk::GdkWindow |  [Windows][GdkWindow]

## Glib library

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|-------------------------|
| GTK::V3::Glib::GError |
| GTK::V3::Glib::GFile |  [File and Directory Handling][GFile]
| GTK::V3::Glib::GInitiallyUnowned |
| GTK::V3::Glib::GInterface |
| GTK::V3::Glib::GList |  [Doubly-Linked Lists][glist]
| GTK::V3::Glib::GMain |  [The Main Event Loop][gmain]
| GTK::V3::Glib::GObject  | [The base object type][gobject]
| GTK::V3::Glib::GSList |  [Singly-Linked Lists][gslist]
| GTK::V3::Glib::GType |  [1) Type Information][GType1], [2) Basic Types][GType2]
| GTK::V3::Glib::GValue |  [1) Generic values][GValue1], [2) Parameters and Values][GValue2]

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

[gtkaboutdialog]: https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html
[gtkbin]: https://developer.gnome.org/gtk3/stable/GtkBin.html
[gtkbuilder]: https://developer.gnome.org/gtk3/stable/GtkBuilder.html
[gtkbutton]: https://developer.gnome.org/gtk3/stable/GtkButton.html
[gtkcheckbutton]: https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
[gtkcontainer]: https://developer.gnome.org/gtk3/stable/GtkContainer.html
[gtkcssprovider]: https://developer.gnome.org/gtk3/stable/GtkCssProvider.html
[gtkdialog]: https://developer.gnome.org/gtk3/stable/GtkDialog.html
[gtkentry]: https://developer.gnome.org/gtk3/stable/GtkEntry.html
[GtkFileChooser]: https://developer.gnome.org/gtk3/stable/GtkFileChooser.html
[GtkFileChooserDialog]: https://developer.gnome.org/gtk3/stable/GtkFileChooserDialog.html
[GtkFileFilter]: https://developer.gnome.org/gtk3/stable/GtkFileFilter.html
[gtkgrid]: https://developer.gnome.org/gtk3/stable/GtkGrid.html
[gtkimage]: https://developer.gnome.org/gtk3/stable/GtkImage.html
[gtkimagemenuitem]: https://developer.gnome.org/gtk3/stable/GtkImageMenuItem.html
[gtklabel]: https://developer.gnome.org/gtk3/stable/GtkLabel.html
[gtklistbox]: https://developer.gnome.org/gtk3/stable/GtkListBox.html
[gtkmain]: https://developer.gnome.org/gtk3/stable/GtkMain.html
[gtkmenuitem]: https://developer.gnome.org/gtk3/stable/GtkMenuItem.html
[gtkradiobutton]: https://developer.gnome.org/gtk3/stable/GtkRadioButton.html
[GtkStyleContext]: https://developer.gnome.org/gtk3/stable/GtkStyleContext.html
[gtktextbuffer]: https://developer.gnome.org/gtk3/stable/GtkTextBuffer.html
[gtktexttagtable]: https://developer.gnome.org/gtk3/stable/GtkTextTagTable.html
[gtktextview]: https://developer.gnome.org/gtk3/stable/GtkTextView.html
[gtktogglebutton]: https://developer.gnome.org/gtk3/stable/GtkToggleButton.html
[gtkwidget]: https://developer.gnome.org/gtk3/stable/GtkWidget.html
[gtkwindow]: https://developer.gnome.org/gtk3/stable/GtkWindow.html

[GdkDisplay]: https://developer.gnome.org/gdk3/stable/GdkDisplay.html
[GdkScreen]: https://developer.gnome.org/gdk3/stable/GdkScreen.html
[GdkWindow]: https://developer.gnome.org/gdk3/stable/gdk3-Windows.html

[gerror]: https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
[GFile]: https://developer.gnome.org/gio/stable/GFile.html
[GInitiallyUnowned]: https://developer.gnome.org/gtk3/stable/ch02.html
[GInterface]: https://developer.gnome.org/gobject/stable/GTypeModule.html
[glist]: https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
[gmain]: https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
[gobject]: https://developer.gnome.org/gobject/stable/gobject-The-Base-Object-Type.html
[gslist]: https://developer.gnome.org/glib/stable/glib-Singly-Linked-Lists.html
[GType1]: https://developer.gnome.org/gobject/stable/gobject-Type-Information.html
[GType2]: https://developer.gnome.org/glib/stable/glib-Basic-Types.html
[GValue1]: https://developer.gnome.org/gobject/stable/gobject-Generic-values.html
[GValue2]: https://developer.gnome.org/gobject/stable/gobject-Standard-Parameter-and-Value-Types.html

<!--
[todo]: https://github.com/MARTIMM/Library/blob/master/doc/TODO.md
[man]: https://github.com/MARTIMM/Library/blob/master/doc/manual.pdf
[requir]: https://github.com/MARTIMM/Library/blob/master/doc/requirements.pdf
-->
