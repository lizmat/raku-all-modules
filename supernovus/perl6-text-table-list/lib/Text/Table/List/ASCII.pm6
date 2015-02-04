use Text::Table::List;

class Text::Table::List::ASCII is Text::Table::List;

### Default drawing characters.
has $.top-left     = "#";
has $.top-right    = "#";
has $.top-char     = "=";
has $.left-char    = "| ";
has $.right-char   = " |";
has $.sep-left     = "+";
has $.sep-right    = "+";
has $.sep-char     = "-";
has $.bottom-left  = "#";
has $.bottom-right = "#";
has $.bottom-char  = "=";

