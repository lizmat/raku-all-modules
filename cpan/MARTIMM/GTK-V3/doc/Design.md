[toc]

# Classes and relations
* Taken from [object hierarchy in GTK docs](https://developer.gnome.org/gtk3/stable/ch02.html) Here is described what is implemented.

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

```plantuml
scale 0.7
hide members
hide circle

class X

class GMain
class GList
class GSList
class GtkMain

class GObject

class GdkScreen
class GdkDisplay
class GdkWindow

GObject <|- GdkScreen
GObject <|-- GdkWindow
GObject <|-- GdkDisplay

GObject <|--- GtkBuilder
GObject <|--- GtkTextBuffer
GObject <|-- GtkCssProvider
```


```plantuml
scale 0.7
hide members
hide circle

GInterface <|-- GtkFileChooser
GInterface <|-- GFile

```
