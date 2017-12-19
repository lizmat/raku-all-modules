use v6;

use PDF::DAO::Dict;
use PDF::Class::Type;

# /Type /Group - a node in the page tree
class PDF::Group
    is PDF::DAO::Dict
    does PDF::Class::Type {

    # see [PDF 1.7 TABLE 10.12 Entries in an object reference dictionary]
    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    my subset Name-Group of PDF::DAO::Name where 'Group';
    has Name-Group $.Type is entry(:required);
}
