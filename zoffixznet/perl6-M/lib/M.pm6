sub EXPORT ($sym = '▸') {
    Map.new: '&postfix:<' ~ $sym ~ '>' => sub (\what) {
        class {
            BEGIN {
                for Any.^methods(:all)».name.grep(
                    * ne any <ACCEPTS new bless BUILDALL>
                ) -> $name {
                    ::?CLASS.^add_method: $name, method (|c) {
                        ::?CLASS.FALLBACK: $name, |c
                    }
                }
            }

            method FALLBACK ($m, |c) {
                what.map: { ."$m"(|c) }
            }
        }
    }
}
