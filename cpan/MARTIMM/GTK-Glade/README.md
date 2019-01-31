![gtk logo][logo]

# GTK::Glade - Accessing Gtk using Glade
<!--
[![Build Status](https://travis-ci.org/MARTIMM/gtk-glade.svg?branch=master)](https://travis-ci.org/MARTIMM/gtk-glade) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/6yaqqq9lgbq6nqot?svg=true&branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending)](https://ci.appveyor.com/project/MARTIMM/gtk-glade/branch/master)
-->
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description
With the modules from package `GTK::Simple` you can build a user interface and interact with it. This package however, is meant to load a user interface description saved by an external designer program. The program used is glade which saves an XML description of the made design.

The user must provide a class which holds the methods needed to receive signals defined in the user interface design.

Then only two lines of code (besides the loading of modules) to let the user interface appear and enter the main loop.

# Synopsis
(Many things shown below will be changed shortly!!)

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

# Motivation
I perhaps should have used parts of `GTK::Simple` but I wanted to study the native call interface which I am now encountering more seriously. Therefore I started a new project with likewise objects as can be found in `GTK::Simple`.

The other reason I want to start a new project is that after some time working with the native call interface. I came to the conclusion that Perl6 is not yet capable to return a proper message when mistakes are made by me e.g. spelling errors or using wrong types. Most of them end up in **MoarVM panic: Internal error: Unwound entire stack and missed handler**. Other times it ends in just a plain crash. I am very confident that this will be improved later but for the time being I had to improve the maintainability of this project by hiding the native stuff as much as possible.

There are some points I noticed in the `GTK::Simple` modules.
* The `GTK::Simple::Raw` module where all the native subs are defined is quite large. Only a few subs can be found elsewhere. That makes the file large and is growing with each addition. Using that module is always a parsing impact despite the several import selection switches one can use.
* I would like to follow the GTK interface more closely when it comes to the native subs. What I want therefore is a class per gtk include file as much as possible. For example there is this file `gtklabel.h` for which I would like to make the class `GtkLabel` in perl6.
* There is no inheritance. A kind of a central role is made which most widget classes use. I would like to have inheritance where for example `GtkLabel` inherits from `GtkWidget`. Then the methods from `GtkWidget` will also be available in `GtkLabel`.
* I want the native subs out of reach of the user. So the `is export` trait is removed. This is important to prevent LTA messages mentioned above.
* When callbacks are defined in GTK, they can accept most of the time some user data to do something with it in the callback. GTK::Simple gives them the OpaquePointer type which renders them useless. Most of the time small Routines are used in place of the handler entry. The code used there can close over the variables you want to use and in that situation there is no problem. This changes when the Routines are defined in a separate sub because of the length or complexity of the code. The data can only be handed over to the Routine using the call interface. What type should I take then. I found out that all kinds can be used so I decided to take `CArray[Str]` to have the most flexible choice.

This will present some problems
* How to store the native widget. This is a central object representing the widget for the class wherein it is created. It is used where widgets like labels, dialogs, frames, listboxes etc are used. Because it is just a pointer to a C object we do not need to build inheritance around this. Like in `GTK::Simple` I used a role for that, only not named after a GTK like class.
* Do I have to write a method for each native sub introduced? Fortunately, that is not necessary. I used the **FALLBACK** mechanism for that. When not found, the search is handed over to the parent. In this process it is possible to accept other names as well which end up finding the same native sub. To let this mechanism work the `FALLBACK` method is defined in the role module. This method will then call the method `fallback` in the modules using the role. When nothing found, `fallback` must call the parents fallback with `callsame`. The subs in some classes all start with some prefix which can be left out too, provided that the fallback functions also test with an added prefix. So e.g. a sub `gtk_label_get_text` defined in class `GtkLabel` can be called like `$label.gtk_label_get_text()` or `$label.get_text()`. As an extra feature dashes can be used instead of underscores, so `$label.gtk-label-get-text()` or `$label.get-text()` works too.
* Is the sub accessible when removing the `is export` trait? No, not directly but because the `fallback` method will search in there own name space they can get hold of the sub reference which is returned to the callers `FALLBACK`. The call then is made with the given arguments prefixed with the native widgets address stored in the role.

Not all of the GTK, GDK or Glib libraries will be covered because not everything is needed, partly because a lot can be designed by the `Glade` user interface designer tool which is the base point of this package. Other reasons are that classes and many subs are deprecated. This package will support the 3.* version of GTK. There is already a 4.* version out but that is food for later thoughts. The root of the library will be GTK::V3 and can be separated later into a another package.

# Documentation

## Glade engine

* GTK::Glade
* GTK::Glade::Engine

## Gtk library

* GTK::V3::Gtk::GtkMain
* GTK::V3::Gtk::GtkLabel is GTK::V3::Gtk::GtkWidget
* GTK::V3::Gtk::GtkWidget

## Gdk library

* GTK::V3::Gdk::GdkDisplay
* GTK::V3::Gdk::GdkScreen
* GTK::V3::Gdk::GdkWindow

## Glib library


## Miscellaneous
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
[logo]: doc/gtk-logo-100.png
<!--
[todo]: https://github.com/MARTIMM/Library/blob/master/doc/TODO.md
[man]: https://github.com/MARTIMM/Library/blob/master/doc/manual.pdf
[requir]: https://github.com/MARTIMM/Library/blob/master/doc/requirements.pdf
-->
