IRC::TextColor
==============

A plugin to style and color text for IRC. It can also convert the ANSIColor text and style from your terminal to IRC Text and style.

### sub ircstyle

```perl6
sub ircstyle(
    Str() $text,
    *%args
) returns Mu
```

a shortened function. Like irc-style-text but you can use shorter versions like C<ircstyle('text', :bold, :green)

### sub irc-style-text

```perl6
sub irc-style-text(
    Str() $text is copy, 
    :$style = 0, 
    :$color = 0, 
    :$bgcolor = 0
) returns Str
```

styles and colors text. returns a copy. Colors allowed: white, blue, green, red, brown, purple, orange, yellow, light_green, teal, light_cyan, light_blue, pink, grey, light_grey.

### sub ansi-to-irc

```perl6
sub ansi-to-irc(
    Str() $text is copy
) returns Str
```

Convert ANSI style/colored text from your terminal output to IRC styled/colored text. Supports both foreground and background color, as well as italic, underline and bold.
