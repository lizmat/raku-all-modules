## Release notes

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
  * Documented GtkAboutDialog

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
