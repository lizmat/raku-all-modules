## Release notes

* 2019-04-15 0.9.1
  * Some subs are added to GOBject.
  * Pod doc added for GObject, GtkBuilder, GtkButton, GtkCheckButton, GtkToggleButton, GtkWidget, GtkWindow.
  * Remove GTK::V3::Glib::GFile. There was no direct use from other classes and in perl6 there are better ways to do IO.

* 2019-03-10 0.9.0
  * Added GtkTextIter to get rid of trickery from GTK::Simple.
  * Added GBoxed to gather methods used in child classes. At the moment GValue and GtkTextIter.
  * Added GtkMisc for hierarchy completeness.

* 2019-02-06 0.8.3
  * Bug fixes

* 2019-03-07 0.8.2
  * The method register-signal() in class GOBject now returns a boolean. True when successful.

* 2019-03-06 0.8.1
  * Readme not completely right for display on internet

* 2019-03-06 0.8.0
  * Added GtkComboBox and GtkComboBoxText and documentation.
  * improved debugging messages.

* 2019-03-02 0.7.3
  * Documentation added and README changed

* 2019-03-02 0.7.2
  * Documentation added and README changed
  * Native subs added

* 2019-03-01 0.7.1
  * Bugfixes.

* 2019-02-28 0.7.0
  * Added GValue and some subs to GObject to handle objects properties.
  * Changes caused by 'at least one underscore' policy. E.g. `gtk-grid-attach()` cannot be shortened to `attach()`. This is done because a class inherits always from `Any` and `Mu` and there are many methods defined there which might clash with a shortened one. A good example is `gtk-button-new()`. A shortened version would be `new()` of which we all know what the purpose is in perl6. The only thing where I'm thinking about is chopping the `g-`, `gdk-` or `gtk-` prefixes. So the last example would become `button-new()`.
  * Added documentation to GtkBin

* 2019-02-25 0.6.2
  * Bugfixes
  * Added documentation to GtkAboutDialog

* 2019-02-23 0.6.1
  * Modified `g_slist_nth_data` into `g_slist_nth_data_str`and `g_slist_nth_data_gobject` because the list can hold several types of data.
  * TODO do same for GList and also more for other types if needed.

* 2019-02-21 0.6.0
  * Added GInitiallyUnowned to make hierarchy better.
  * Added GtkFileChooserDialog, GtkFileChooser, GtkFileFilter and GFile.
  * Added GInterface to hook GtkFileChooser.
  * Added more subs to GtkAboutDialog

* 2019-02-20 0.5.0
  * Added GSList and GtkRadioButton
  * Documented GtkAboutDialog. Docs are available as pdf in the doc directory.

* 2019-02-18 0.4.3
  * Bugfixes

* 2019-02-16 0.4.2
  * Improve of widget creation
  * Added :build-id option to widget creation. Can only be used when a builder is created with a gui description. Then, a widget can be searched in this description.

* 2019-02-15 0.4.1
  * Bugfixes
  * Module GdkTypes for use in other classes

* 2019-02-14 0.4.0
  * Module GObject placed at the top of the foodchain.
  * Automatic initialization of GTK before first access of a native sub.

* 2019-02-11 0.3.0
  * New modules GtkDialog, GtkAboutDialog, GtkImage, GtkEntry, GtkCheckButton, GtkToggleButton, GtkListBox, GtkWindow, GtkMenuItem, GtkImageMenuItem

* 2019-02-08 0.2.0
  * Connecting signals
  * New modules GtkCssProvider, GtkTextBuffer, GtkTextView

* 2019-02-04 0.1.0
  * New modules GtkGrid and GList

* 2019-01-24 0.0.1
  * Start of project which is separated from GTK::Glade
