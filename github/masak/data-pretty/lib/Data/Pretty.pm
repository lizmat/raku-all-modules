use MONKEY_TYPING;

augment class Hash {
    multi method gist is default {
        '{' ~ ($.pairs.sort.map( -> $elem {
                given ++$ {
                    when 101 { '...' }
                    when 102 { last }
                    default  { $elem.gist }
                }
            } ).join: ', ') ~ '}'
    }
}

augment class Array {
    method gist {
        '[' ~ $.map(*.gist).join(', ') ~ ']'
    }
}

augment class List {
    multi method gist is default {
        '(' ~ $.map(*.gist).join(', ') ~ ')'
    }
}

augment class Parcel {
    multi method gist is default {
        '(' ~ $.map(*.gist).join(', ') ~ ')'
    }
}

augment class Sub {
    method gist {
        '&' ~ ($.name || '<anon>')
    }
}

augment class Regex {
    method gist {
        '<regex>'
    }
}
