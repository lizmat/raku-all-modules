![gtk logo][logo]

# GTK::Glade - Accessing Gtk using Glade
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description
With the modules from package `GTK::Simple` you can build a user interface and interact with it. This package however, is meant to load a user interface description saved by an external designer program. The program used is glade which saves an XML description of the made design.

The user must provide a class which holds the methods needed to receive signals defined in the user interface design.

Then only two lines of code (besides the loading of modules) is needed to let the user interface appear and enter the main loop.

# Synopsis
### User interface file
The first thing to do is designing a ui and save it. A part of the saved result is shown below. It shows the part of an exit button. Assume that this file is saved in **example.glade**.
```
<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated with glade 3.20.0 -->
<interface>
  <requires lib="gtk+" version="3.0"/>
  <object class="GtkWindow" id="window">
...
          <object class="GtkButton" id="quit">
            <property name="label">Quit</property>
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="receives_default">False</property>
            <signal name="clicked" handler="quit-program"/>
          </object>
...
</interface>

```

### Class for signal handlers
Then write code to handle all signals which are defined by the user interface. These modules are called engines. You do not have to write every handler at once. You will be notified about a missing handler as soon as an event is fired for it. Only the method to handle a click event from the quit button is shown below in the example. This example file is saved in **lib/MyEngine.pm6**.

```
use v6;
use GTK::Glade;
use GTK::Glade::Engine;


unit class MyEngine;
also is GTK::Glade::Engine;


# $widget is the activated button after which this method is called. Methods
# are from GTK::V3::Gtk::GtkButton. See documentation in the GTK::V3 project.
method quit-program ( :$widget ) {

  note "Button label: ", $widget.get-label($widget);
  note "Button name is by default button's class name: ", $widget.get-name;

  self.glade-main-quit();
}
  ...
```

### The main program
The rest is a piece of cake.
```
use v6;
use MyEngine;
use GTK::Glade;

my GTK::Glade $gui .= new;
$gui.add-gui-file("example.glade");
$gui.add-engine(MyEngine.new);
$gui.run;
```

# Documentation

* [GTK::Glade](https://modules.perl6.org/dist/GTK::Glade:cpan:MARTIMM/doc/Glade.pdf)
* GTK::Glade::Engine

## Miscellaneous
* [Release notes](https://modules.perl6.org/dist/GTK::Glade:cpan:MARTIMM/doc/CHANGES.md)

# TODO

* [ ] What can we do with the GTK::Glade object after it exits the main loop.
* [ ] Documentation.

# Versions of involved software

* Program is tested against the latest version of **perl6** on **rakudo** en **moarvm**.
* Used **glade** version is **>= 3.22**
* Generated user interface file is for **Gtk >= 3.10**

# Installation of GTK::Glade

`zef install GTK::Glade`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**


<!---- [refs] ----------------------------------------------------------------->
[release]: https://github.com/MARTIMM/gtk-glade/blob/master/doc/CHANGES.md
[logo]: doc/gtk-logo-100.png
