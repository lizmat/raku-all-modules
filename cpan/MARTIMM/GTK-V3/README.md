![gtk logo][logo]

# GTK::V3 - Accessing Gtk version 3.*
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description
First of all, I would like to thank the developers of the GTK::Simple project because of the information I got while reading the code. Also because one of the files is copied unaltered for which I did not had to think about to get that right.

The purpose of this project is to create an interface to the **GTK** version 3 library. Previously I had this library in GTK::Glade project but because of its growth I decided to create a separate project.

I want to follow the interface of the classes in **Gtk**, **Gdk** and **Glib** as closely as possible by keeping the names of the native functions the same as provided with the following exceptions;
* The native subroutines are defined in their classes. They are setup in such a way that they have become methods in those classes. Many subs also have as their first argument the native object. This object is held in the class and is automatically inserted when needed. E.g. a definition like the following in the GtkButton class
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

* Classes can use the methods of inherited classes. E.g. The GtkButton class inherits GtkBin and GtkBin inherits GtkContainer etcetera. Therefore a method like `gtk_widget_set_tooltip_text` from `GtkWidget` can be used.
```
$button.gtk_widget_set_tooltip_text('When pressed, program will start');
```

* The names are sometimes long and prefixed with words which are used in the class name. Therefore, those names can be shortened by removing those prefixes. An example method in the `GtkButton` class is `gtk_button_get_label()`. This can be shortened to `get_label()`.
```
my Str $button-label = $button.get_label;
```
  In the documentation this will be shown with brackets around the part that can be left out. In this case is is shown as `[gtk_button_] get_label`.

* Names can not be shortened too much. E.g. `gtk_button_new` and `gtk_label_new` yield `new` which is a perl method from class `Mu`. I am thinking about chopping off the `g_`, `gdk_` and `gtk_` prefixes.

* All the method names are written with an underscore. Following a perl6 tradition, dashed versions is also possible.
```
my Str $button-label = $button.gtk-button-get-label;
```
  or
```
my Str $button-label = $button.get-label;
```

* Sometimes I had to stray away from the native function names because of the way one has to define it in perl6. This is caused by the possibility of returning or specifying different types of values depending on how the function is used. E.g. `g_slist_nth_data()` can return several types of data. This is solved using several subs linking to the same native sub. In this library, the methods `g_slist_nth_data_str()` and `g_slist_nth_data_gobject()` are created. This can be extended for integers, reals and other types.

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
  Other causes are variable argument lists where I had to choose for the extra arguments. E.g. in the `GtkFileChooserDialog` the native sub `gtk_file_chooser_dialog_new` has a way to extend it with a number of buttons on the dialog. I had to fix that list to a known number of arguments and renamed the sub `gtk_file_chooser_dialog_new_two_buttons`.

* Not all native subs or even classes will be implemented or implemented much later because of the following reasons;
  * Many subs and some classes are obsolete.
  * The original idea was to have the interface build by the glade interface designer. This lib was in the GTK::Glade project before re-factoring. Therefore a GtkButton does not have to have all subs to create a button. On the other hand a GtkListBox is a widget which is changed dynamically most of the time and therefore need more subs to manipulate the widget and its contents.
  * The need to implement classes like GtkAssistant, GtkAlignment or GtkScrolledWindow is on a low priority because these can all be instantiated by `GtkBuilder` using your Glade design.

* There are native subroutines which need a native object as an argument. The `gtk_grid_attach` in `GtkGrid` is an example of such a routine. It is possible to provide the perl6 object in that place. The signature of the native sub is checked and will automatically retrieve the native object from that class if needed.

  The definition of the native sub;
```
sub gtk_grid_attach (
  N-GObject $grid, N-GObject $child,
  int32 $x, int32 $y,
  int32 $width, int32 $height
) is native(&gtk-lib)
  { * }
```
  And its use;
```
my GTK::V3::Gtk::GtkGrid $grid .= new(:empty);
my GTK::V3::Gtk::GtkLabel $label .= new(:label('server name'));
$grid.gtk-grid-attach( $label, 0, 0, 1, 1);
```

# Errors and crashes

I came to the conclusion that Perl6 is not (yet) capable to return a proper message when mistakes are made by me e.g. spelling errors or using wrong types when using the native call interface. Most of them end up in **MoarVM panic: Internal error: Unwound entire stack and missed handler**. Other times it ends in just a plain crash. Some of the crashes are happening within GTK and cannot be captured by Perl6. One of those moments are the use of GTK calls without initializing GTK with `gtk_init`. The panic mentioned above mostly happens when perl6 code is called from C as a callback. The stack might not be interpreted completely at that moment hence the message.

A few measures are implemented to help a bit preventing problems;

  * The failure to initialize GTK on time is solved by using an initialization flag which is checked in the `GtkMain` module. The module is referred to by `GObject` which almost all modules inherit from.
  * A debug flag in `GObject` can be set to show some more messages which might help to solve your problems.
  * Throwing an exception while in code called from C (in a callback), perl6 will crash with the '*internal error*' message without being able to process the exception. To at least show why it happens, all messages which are set in the exception are printed first before calling `die()` which will perl6 force to wander off aimlessly.

# Documentation

## Gtk library

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|-------------------------|
| [GTK::V3::Gtk::GtkAboutDialog](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkAboutDialog.pdf) | [GtkAboutDialog.html][gtkaboutdialog]
| [GTK::V3::Gtk::GtkBin](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkBin.pdf) | [GtkBin.html][gtkbin]
| GTK::V3::Gtk::GtkBuilder |  [GtkBuilder.html][gtkbuilder]
| GTK::V3::Gtk::GtkButton |  [GtkButton.html][gtkbutton]
| GTK::V3::Gtk::GtkCheckButton |  [GtkCheckButton.html][gtkcheckbutton]
| [GTK::V3::Gtk::GtkComboBox](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkComboBox.pdf) |  [GtkComboBox.html][GtkComboBox]
| [GTK::V3::Gtk::GtkComboBoxText](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkComboBoxText.pdf) |  [GtkComboBoxText.html][GtkComboBoxText]
| GTK::V3::Gtk::GtkContainer |  [GtkContainer.html][gtkcontainer]
| GTK::V3::Gtk::GtkCssProvider |  [GtkCssProvider.html][gtkcssprovider]
| GTK::V3::Gtk::GtkStyleContext |  [GtkStyleContext.html][gtkstylecontext]
| [GTK::V3::Gtk::GtkDialog](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkDialog) |  [GtkDialog.html][gtkdialog]
| GTK::V3::Gtk::GtkEntry |  [GtkEntry.html][gtkentry]
| GTK::V3::Gtk::GtkFileChooser |  [GtkFileChooser.html][GtkFileChooser]
| [GTK::V3::Gtk::GtkFileChooserDialog](https://modules.perl6.org/dist/GTK::V3:cpan:MARTIMM/doc/GtkFileChooserDialog.pdf) |  [GtkFileChooserDialog.html][GtkFileChooserDialog]
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
| GTK::V3::Glib::GSignal  | [The base object type][GSignal]
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
Github account name: **MARTIMM**


<!---- [refs] ----------------------------------------------------------------->
[release]: https://github.com/MARTIMM/gtk-glade/blob/master/doc/CHANGES.md
[logo]: doc/gtk-logo-100.png

[gtkaboutdialog]: https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html
[gtkbin]: https://developer.gnome.org/gtk3/stable/GtkBin.html
[gtkbuilder]: https://developer.gnome.org/gtk3/stable/GtkBuilder.html
[gtkbutton]: https://developer.gnome.org/gtk3/stable/GtkButton.html
[gtkcheckbutton]: https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
[GtkComboBox]: https://developer.gnome.org/gtk3/stable/GtkComboBox.html
[GtkComboBoxText]: https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-append
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
[GSignal]: https://developer.gnome.org/gobject/stable/gobject-Signals.html
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
