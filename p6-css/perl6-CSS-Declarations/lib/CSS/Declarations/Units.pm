use v6;

#| utility definitions and operators for handing CSS Units
#| at the moment this is restricted to length units and only
#| the '+' and '-' operators are handled.

module CSS::Declarations::Units {
    my enum Units is export « :pt(1.0) :pc(12.0) :px(.75) :mm(2.8346) :cm(28.346) :in(72.0) »;
    role Type[$type] { method type{$type} }
    subset Length of Type is export where .type eq 'pt'|'pc'|'px'|'mm'|'cm'|'in';
    sub postfix:<pt>(Numeric $v) is rw is export { $v but Type['pt']  };
    sub postfix:<pc>(Numeric $v) is rw is export { $v but Type['pc']  };
    sub postfix:<px>(Numeric $v) is rw is export { $v but Type['px']  };
    sub postfix:<mm>(Numeric $v) is rw is export { $v but Type['mm']  };
    sub postfix:<cm>(Numeric $v) is rw is export { $v but Type['cm']  };
    sub postfix:<in>(Numeric $v) is rw is export { $v but Type['in']  };
    sub postfix:<em>(Numeric $v) is rw is export { $v but Type['em']  };
    sub postfix:<ex>(Numeric $v) is rw is export { $v but Type['ex']  };
    sub postfix:<%>(Numeric $v) is rw is export { $v but Type['percent']  };
    constant &Add = &infix:<+>;
    constant &Sub = &infix:<->;
    multi sub infix:<+>(Length $v, Length $n) is export {
        my \scale = $v.type eq $n.type
            ?? 1
            !! Units.enums{$n.type} / Units.enums{$v.type};
        &Add($v.Numeric, scale * $n.Numeric) but Type[$v.type];
    }
    multi sub infix:<->(Length $v, Length $n) is export {
        my \scale = $v.type eq $n.type
            ?? 1
            !! Units.enums{$n.type} / Units.enums{$v.type};
        &Sub($v.Numeric, scale * $n.Numeric) but Type[$v.type];
    }
}
