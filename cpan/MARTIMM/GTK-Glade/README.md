# GTK::Glade - Accessing Gtk UI using Glade IDE

<!--
[![Build Status](https://travis-ci.org/MARTIMM/gtk-glade.svg?branch=master)](https://travis-ci.org/MARTIMM/gtk-glade) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/6yaqqq9lgbq6nqot?svg=true&branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending)](https://ci.appveyor.com/project/MARTIMM/gtk-glade/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)
-->

# Description
With the modules from package `GTK::Simple` you can build a user interface and interact with it. This package however, is meant to load a user interface description which is saved by an external designer program. The program used is glade which saves an XML description of the made design.

The user must provide a class which holds the methods needed to receive signals defined in the ui-design. This might be extended later on.

Then only two lines of code (besides the loading of modules) to let the ui appear and enter the main loop.

# Synopsis

#### User interface file
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

#### Class for signal handlers
Then write code to handle all signals which are defined by the user interface. Don't have to write every handler at once. You will be notified about a missing handler as soon as an event is fired for it. Only the method to handle a click event from the quit button is shown. This file is saved in **lib/MyEngine.pm6**.

```
use v6;
use GTK::Glade;

class MyEngine is GTK::Glade::Engine {

  #-----------------------------------------------------------------------------
  method quit-program ( :$widget, :$data, :$object ) {

    note "Button label: ", gtk_button_get_label($widget);
    note "Button name is by default button's class name: ",
         gtk_widget_get_name($widget);

    gtk_main_quit();
  }

  ...
}

```
Above are a few examples of gtk subroutines which are mostly defined in ` GTK::Glade::NativeGtk` which is pinched largely from the GTK::Simple package. A few missing subs were added and others were modified or removed. Examples used above are `gtk_button_get_label()`, `gtk_widget_get_name()` and `gtk_main_quit()`.


#### The main program
The rest is a piece of cake.
```
use v6;
use MyEngine;
use GTK::Glade;

# Instantiate your engine class with whatever your class needs
my MyEngine $engine .= new();

# Instantiate the api class, display the designed interface
# and enter the main loop
my GTK::Glade $a .= new( :ui-file("example.glade"), :$engine);
```

# Documentation

* [Release notes][release]

# TODO

* [ ] What can we do with the GTK::Glade object after it exits the main loop.
* [ ] Name changes: E.g It feels a bit that 'Engine' is not a proper name. Better something with 'Handler' in it. It all depends on what is added later.
* [ ] Need to test more things like adding or modifying content of widgets.
* [x] Add css files
* [ ] Add theme styling
* [ ] Add animation
* [x] Add an interface tester so it can be tested using prove. Only the callbacks can be tested. However, it cannot be used to test stuff on Travis-ci or Appveyor.
* [ ] Documentation.

# Versions of involved software

* Program is tested against the latest version of **perl6** on **rakudo** en **moarvm**.
* Used **glade** version is **>= 3.22**
* Generated user interface file is for **Gtk >= 3.10**


# Installation of GTK::Glade

`zef install GTK::Glade`


# Author

Name: **Marcel Timmerman**
Github account name: Github account MARTIMM


<!---- [refs] ----------------------------------------------------------------->
[release]: https://github.com/MARTIMM/gtk-glade/blob/master/doc/CHANGES.md

<!--
[todo]: https://github.com/MARTIMM/Library/blob/master/doc/TODO.md
[man]: https://github.com/MARTIMM/Library/blob/master/doc/manual.pdf
[requir]: https://github.com/MARTIMM/Library/blob/master/doc/requirements.pdf
-->
