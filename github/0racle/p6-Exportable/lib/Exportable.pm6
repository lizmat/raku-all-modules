unit module Exportable:ver<0.0.2>;

multi sub exported-EXPORT(%exports, *@names --> Hash()) {
    do for @names -> $name {
        unless %exports{ $name }:exists {
            die("Unknown name for export: '$name'");
        }
        "&$name" => %exports{ $name }
    }
}

multi sub EXPORT {
    my %exports;
    multi sub trait_mod:<is>(Routine:D \r, Bool :$exportable!) is export {
        trait_mod:<is>(r, :exportable(r.name => True));
    }
    multi sub trait_mod:<is>(Routine:D \r, :$exportable!) is export {
        trait_mod:<is>(r, :export($exportable));
        %exports{ r.name } = r
    }
    {
        '&EXPORT' => sub (*@names) { exported-EXPORT %exports, |@names }
    }
}
