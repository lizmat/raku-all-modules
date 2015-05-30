use v6;

use CSS::Specification::Terms;

grammar CSS::Specification::Terms::CSS3
    is CSS::Specification::Terms {

    # http://www.w3.org/TR/2013/CR-css3-values-20130404/ 3.1.1
    # - all properties accept the 'initial' and 'inherit' keywords
    token proforma:sym<inherit> {:i inherit}
    token proforma:sym<initial> {:i initial}

    # base colors - may be extended by css::module::css3::colors
    rule color:sym<named> {:i [ aqua | black | blue | fuchsia | gray | green | lime | maroon | navy | olive | orange | purple | red | silver | teal | white | yellow ] & <keyw> }

    # base resolution units - may be extended by Units and Values module
    token resolution-units {:i[dpi|dpcm]}
    proto token resolution {*}
    token resolution:sym<dim> {<num>(<.resolution-units>)}
    token dimension:sym<resolution> {<resolution>}
}

