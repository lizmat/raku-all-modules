# X (as XML) because i don't have a better name

this module is a port of the [perl5 X experiment](https://github.com/eiro/p5-x).

# notes from Scratchpad

things to test 

    module X::html {}


    sub p (*%attrs, *@data) {
        "<p"
        , %attrs.kv.map( -> $k, $v {
            if ( $v ~~ Bool ) { Q:qq< $k> } 
            else              { Q:qq< $k="$v"> } 
        }), ">", @data , "</p>";
    }

    sub EXPORTER {
        { < p div >.map:
            -> $tag { $_ => -> $tag ($v) { "<$tag>$v</$tag>" } }
        }
    }
