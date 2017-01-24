use v6;

# CSS3 Media Queries Extension Module
# - specification: http://www.w3.org/TR/2012/REC-css3-mediaqueries-20120619/
#
# The CSS3 Core includes some basic CSS2.1 compatible @media at rules. This
# module follows the latest W3C recommendations, to extend the syntax.
#
# -- if you want the capability to to embed '@page' rules, you'll also need
#    to load the Paged Media extension module in your class structure.
class CSS::Module::CSS3::MediaQueries::Actions {...}

class CSS::Module::CSS3::MediaQueries { #:api<css3-mediaqueries-20120619>

    use CSS::Grammar;

    rule at-rule:sym<media> {'@'(:i'media') [<media-list>||<media-list=.unknown-media-list>] <rule-list> }

    rule rule-list {
        '{' [ <at-rule> | <ruleset> ]* <.end-block>
    }

    rule unknown-media-list  { <CSS::Grammar::Core::_any>* }
    rule media-query {[<media-op>? <media-name> | '(' <media-expr> ')']
                      [ <keyw(/:i and/)> '(' <media-expr> ')' ]*}
    rule media-op    {:i'only'|'not'}

    rule _range {:i [$<prefix>=[min|max]\-]}
    rule media-expr  { <expr=.media-feature> || <media-feature-unknown> }

    proto rule media-feature  {*}

    #| [min-|max-]?[device-]?width: <length>
    rule media-feature:sym<width> {:i (<._range>?[device\-]?width) ':' <val( rx{ <expr=.media-expr-length> }, &?ROUTINE.WHY)> }

    #| [min-|max-]?[device-]?height: <length>
    rule media-feature:sym<height> {:i (<._range>?[device\-]?height) ':' <val( rx{ <expr=.media-expr-length> }, &?ROUTINE.WHY)> }
    rule media-expr-length { <length> }

    #| orientation: [portrait | landscape]?
    rule media-feature:sym<orientation> {:i (orientation) [ ':' <val( rx{ <expr=.media-expr-orientation> }, &?ROUTINE.WHY)> ]? }
    rule media-expr-orientation {:i [ portrait | landscape ] & <keyw> }

    #| [min-|max-]?[device-]?aspect-ratio: <horizontal> "/" <vertical>   (e.g. "16/9")
    rule media-feature:sym<aspect-ratio> {:i (<._range>?[device\-]?aspect\-ratio) ':' <val( rx{ <expr=.media-expr-aspect> },  &?ROUTINE.WHY)> }
    rule media-expr-aspect {:i <horizontal=.integer> '/' <vertical=.integer> }

    #| [min-|max-]?color[-index]?: <integer>
    rule media-feature:sym<color> {:i (<._range>?color[\-index]?) ':' <val( rx{ <expr=.media-expr-color> }, &?ROUTINE.WHY)> }
    #| color[-index]?
    rule media-feature:sym<color-bool> {:i (color[\-index]?) <!before ':'> }

    #| [min-|max-]?monochrome: <integer>
    rule media-feature:sym<monochrome> {:i (<._range>?monochrome) ':' <val( rx{  <expr=.media-expr-color> }, &?ROUTINE.WHY)> }
    rule media-expr-color {:i <integer> }

    #| [min-|max-]?resolution: <resolution>
    rule media-feature:sym<resolution> {:i (<._range>?resolution) ':' <val( rx{ <expr=.media-expr-resolution> }, &?ROUTINE.WHY)> }
    rule media-expr-resolution { <resolution> }

    #| scan: [progressive | interlace]?
    rule media-feature:sym<scan> {:i (scan) [ ':' <val( rx{ <expr=.media-expr-scan> }, &?ROUTINE.WHY)> ]? }
    rule media-expr-scan {:i [ progressive | interlace ] & <keyw> }

    #| grid [: <integer>]?
    rule media-feature:sym<grid> {:i (grid) [ ':' <val( rx{  <expr=.media-expr-grid> }, &?ROUTINE.WHY)> ]? }
    rule media-expr-grid {:i [0 | 1 ] & <integer> }

    rule media-feature-unknown  { (<.Ident>) [ ':' <any>* ]? }

}

class CSS::Module::CSS3::MediaQueries::Actions {

        use CSS::Grammar::AST :CSSValue;

    # rule-list, media-list, media see core grammar actions
    method unknown-media-list($/) {
	$.warning("discarding media list");
        make [{"media-query" => [{keyw => "not"}, {ident => "all"}]}];
    }

    method media-query($/) {
        return make [{keyw => "not"}, {ident => "all"}]
            if @<media-expr> && @<media-expr>.grep({! .ast.defined});

	make $.list($/);
    }

    method media-op($/) {
        make $.token($/.lc, :type<keyw>);
    }

    method media-expr($/) {
	make $.token( $.decl($<expr>, :proforma()), :type(CSSValue::Property) )
            if $<expr>;
    }

    method media-feature-unknown($/)   {
        $.warning('unknown media-feature', lc($0));
    }
}
