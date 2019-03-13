[toc]

# Class hierargy
* Below are diagrams of what is implemented. See also the [object hierarchy in GTK docs](https://developer.gnome.org/gtk3/stable/ch02.html).


```plantuml
@startmindmap
scale 0.7

title GTK Class hierary
* GObject
 * GInitiallyUnowned
  * GtkWidget
   * GtkMisc
    * GtkEntry
    * GtkImage
    * GtkLabel
   * GtkContainer
    * ...

  * GtkFileFilter

 * GdkScreen
 * GdkWindow
 * GdkDisplay

 * GtkBuilder
 * GtkTextBuffer
 * GtkCssProvider
@endmindmap
```

```plantuml
@startmindmap
scale 0.7

title GTK Class hierary at GtkContainer

* GtkContainer
 * GtkBin
  * GtkButton
   * GtkToggleButton
    * GtkCheckButton
     * GtkRadioButton

  * GtkWindow
   * GtkDialog
    * GtkAboutDialog
    * GtkFileChooserDialog

  * GtkMenuItem
   * GtkImageMenuItem

 * GtkTextView
@endmindmap
```


```plantuml
@startmindmap
scale 0.7
title Interface classes
* GInterface
 * GFile
 * GtkFileChooser

@endmindmap
```

```plantuml
@startmindmap
scale 0.7
title Wrapped structure classes
* GBoxed
 * GValue
 * GtkTextIter

@endmindmap
```

```plantuml
@startmindmap
scale 0.7
title Standalone classes

*_ .
 * X
 * GMain
 * GList
 * GSList
 * GType
 * GSignal
 * GtkMain
@endmindmap
```




<!-- Restjes ...

```plantuml
scale 0.7
hide members
hide circle

'class Gui
'class GSignal
'GSignal <|-- GtkWidget
'X <-* Gui


GtkBin <|-- GtkButton
GtkButton <|-- GtkToggleButton
GtkToggleButton <|-- GtkCheckButton
GtkCheckButton <|-- GtkRadioButton

GtkBin <|-- GtkWindow
GtkWindow <|-- GtkDialog
GtkDialog <|-- GtkAboutDialog
GtkDialog <|-- GtkFileChooserDialog

GtkWidget <|-- GtkLabel
GtkWidget <|-- GtkEntry

GtkContainer <|-- GtkBin
GtkContainer <|-- GtkTextView
GtkWidget <|-- GtkContainer

GInitiallyUnowned <|-- GtkWidget
GObject <|-- GInitiallyUnowned

GtkBin <|-- GtkMenuItem
GtkMenuItem <|-- GtkImageMenuItem

GInitiallyUnowned <|-- GtkFileFilter

```
-->
