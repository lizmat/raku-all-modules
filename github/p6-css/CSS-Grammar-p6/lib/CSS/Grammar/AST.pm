use v6;

class CSS::Grammar::AST {

    # These tables map AST types to standard W3C component definitions.

    # CSS object definitions based on http://dev.w3.org/csswg/cssom/
    # for example 6.4.1 CSSRuleList maps to CSSObject::RuleList
    our Str enum CSSObject is export(:CSSObject) «
        :AtRule<at-rule>
        :Priority<prio>
        :RuleSet<ruleset>
        :RuleList<rule-list>
        :StyleDeclaration<style>
        :StyleRule<style-rule>
        :StyleSheet<stylesheet>
        »;

    # CSS value types based on http://dev.w3.org/csswg/cssom-values/
    # for example 3.3 CSSStyleDeclarationValue maps to CSSValue::StyleDeclaration
    our Str enum CSSValue is export(:CSSValue) «
        :ColorComponent<color>
        :Component<value>
        :IdentifierComponent<ident>
        :KeywordComponent<keyw>
        :LengthComponent<length>
        :Map<map>
        :PercentageComponent<percent>
        :Property<property>
        :PropertyList<declarations>
        :StringComponent<string>
        :URLComponent<url>

        :NameComponent<name>
        :NumberComponent<num>
        :IntegerComponent<int>
        :AngleComponent<angle>
        :FrequencyComponent<freq>
        :FunctionComponent<func>
        :ResolutionComponent<resolution>
        :TimeComponent<time>
        :QnameComponent<qname>
        :OtherUnitComponent<units>
        :NamespacePrefixComponent<ns-prefix>
        :ElementNameComponent<element-name>
        :OperatorComponent<op>
        :ExpressionComponent<expr>
        :ArgumentListComponent<args>
        :AtKeywordComponent<at-keyw>
        :UnicodeRangeComponent<unicode-range>
    »;

    our Str enum CSSSelector is export(:CSSSelector) «
        :AttributeSelector<attrib>
        :Class<class>
        :Id<id>
        :MediaList<media-list>
        :MediaQuery<media-query>
        :PseudoClass<pseudo-class>
        :PseudoElement<pseudo-elem>
        :PseudoFunction<pseudo-func>
        :SelectorList<selectors>
        :Selector<selector>
        :SelectorComponent<simple-selector>
    »;

    # an enumerated list of all unit types for validation purposes.
    # Adapted from the out-of-date http://www.w3.org/TR/DOM-Level-2-Style/css.html

    our Str enum CSSUnits is export(:CSSUnits) «
        :ems<length> :exs<length> :px<length> :cm<length> :mm<length> :in<length> :pt<length> :pc<length>
        :em<length> :ex<length> :rem<length> :ch<length> :vw<length> :vh<length> :vmin<length> :vmax<length>
        :dpi<resolution> :dpcm<resolution> :dppx<resolution>
        :deg<angle> :rad<angle> :grad<angle> :turn<angle>
        :ms<time> :s<time>
        :hz<freq> :khz<freq>
        :rgb<color> :rgba<color> :hsl<color> :hsla<color>
    »;

    # from http://dev.w3.org/csswg/cssom-view/
    our Str enum CSSTrait is export(:CSSTrait) «:Box<box>»;

BEGIN our %known-type =
    %( CSSObject.enums.invert ),
    %( CSSValue.enums.invert ),
    %( CSSSelector.enums.invert ),
    ;


    #| utility token builder method, e.g.: $.token(42, :type<cm>)  -->   :cm(42)
    method token(Mu $ast, Str :$type is copy) {

        die 'usage: $.token($ast, :$type)'
            unless $type;

        return unless $ast.defined;

        my Str $units = $type;
	$type = CSSUnits.enums{$type}
	    if CSSUnits.enums{$type}:exists;

	my ($raw-type, $_class) = $type.split(':');
	die "unknown type: '$raw-type'"
	    unless %known-type{$raw-type}:exists;

        $ast.isa(Pair)
            ?? ($units => $ast.value)
	    !! ($units => $ast);
    }

    #| utility AST builder method for leaf nodes (no repeated tokens)
    method node($/ --> Hash) {
        my %terms;

        # unwrap Parcels
        my @l = $/.can('caps')
            ?? ($/)
            !! $/.grep: *.defined;

        for @l {
            for .caps -> $cap {
                my ($key, $value) = $cap.kv;
                next if $key eq '0';
                $key = $key.lc;
                my ($type, $_class) = $key.split(':');

                $value = $value.ast
                    // next;

                if substr($key, 0, 5) eq 'expr-' {
                    $key = 'expr:' ~ substr($key, 5);
                }
                elsif $value.isa(Pair) {
                    ($key, $value) = $value.kv;
                }
                elsif %known-type{$type}:!exists {
                    warn "{$value.perl} has unknown type: $type";
                }

                if %terms{$key}:exists {
                    $.warning("repeated term " ~ $key, $value);
                    return Any;
                }

                %terms{$key} = $value;
            }
        }

        %terms;
    }

    #| utility AST builder method for nodes with repeatable elements
    method list($/ --> Array) {
        my @terms;

        # unwrap Parcels
        my @l = $/.can('caps')
            ?? ($/)
            !! $/.grep: *.defined;

        for @l {
            for .caps -> $cap {
                my ($key, $value) = $cap.kv;
                next if $key eq '0';
                $key = $key.lc;

                my ($type, $_class) = $key.split(':');

                $value = $value.ast
                    // next;

                if substr($key, 0, 5) eq 'expr-' {
                    $key = 'expr:' ~ substr($key, 5);
                }
                elsif $value.isa(Pair) {
                    ($key, $value) = $value.kv;
                }
                elsif %known-type{$type}:!exists {
                    warn "{$value.perl} has unknown type: $type";
                }

                push( @terms, {$key => $value} );
            }
        }

        @terms;
    }

}
