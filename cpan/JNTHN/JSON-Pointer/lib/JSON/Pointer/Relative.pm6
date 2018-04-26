use v6.c;

use JSON::Pointer;

grammar JSONPointerRelative {
    token TOP { <positive> '#' | <positive> <JSONPointer::TOP>  }
    token positive { '0' | <[1..9]> <[0..9]>* }
    
}
