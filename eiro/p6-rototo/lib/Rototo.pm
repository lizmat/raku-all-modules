module Rototo {

    sub _attr (%attrs) {
        %attrs.kv.map: 
            -> $k, $v {
            if ( $v ~~ Bool ) { Q:qq< $k> } 
            else              { Q:qq< $k="$v"> } }
    }

    sub mktag (Str $tag, :$empty=False ) is export {
        if $empty {
            sub (*%attrs) { "<$tag" , (_attr %attrs) , "/>"
            }
        } else {
            sub (*%attrs, *@data) {
                "<$tag" , (_attr %attrs), ">"
                , |@data
                , "</$tag>";
            }
        }
    }

    # sub export-tag (Str $tag, :$as = $tag ) is export { "\&:$as" => mktag $tag }
} 

