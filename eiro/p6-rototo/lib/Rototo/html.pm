# module X::html {}

use Rototo;

sub EXPORT {
    %(|< a
        html head title 
        body
        div span p
        ul ol li
        dd dt dl
        h1 h2 h3 h4 h5 h6
        script style
        pre code
        section footer header aside nav article
        quote blockquote
        img
        textarea fieldset form label
        table col colgroup caption tbody thead tfoot th
        input
        tr td link
        >.map( -> $tag { "\&$tag" => mktag $tag})
        , |< br meta >.map( -> $tag { "\&$tag" => mktag $tag, :empty })
    )
}
