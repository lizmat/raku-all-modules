unit class Tag;

use HTML::Entity;

#| Assign ' /' for XHTML
our $.self-closing-marker = '';

#| Elements that dont have any embed content
our @.void-elements = < area base br col command embed hr img input gen link meta param source track wbr >;

#| Attributes that dont have any content
our @.boolean-attributes = < async checked compact declare defer disabled ismap multiple noresize noshade nowrap open readonly required reversed scoped selected >;

has $!value;

submethod BUILD(:$!value = '') {
    # allow private attribute in default constructor
}

method Str {
    $!value
}

method gist {
    self.Str
}

method FALLBACK(Str $name, *@args, *%attrs) {
    my $attr = '';
    my $value = self;

    # build attr string out of hash
    for %attrs.kv -> $k, $v {
        if @.boolean-attributes.any ~~ $k.lc {
            if $v {
                $attr ~= $.self-closing-marker ?? " $k=\"$k\"" !! " $k";
            }
        } else {
            $attr ~= " $k=\"{ encode-entities($v) }\""
        }
    }

    # encode everything that is not a Tag object
    @args = @args.map: -> $e {
        $e !~~ Tag ?? encode-entities($e) !! $e;
    };

    # build tag
    given $name.lc {
        when /^begin_/ {
            $value ~= "<{ $name.substr(6) ~ $attr }>";
        }
        when /^end_/ {
            $value ~= "</{ $name.substr(4) }>";
        }
        when @.void-elements.any {
            $value ~= "<$name$attr$.self-closing-marker>";
        }
        default {
            $value ~= "<$name$attr>{@args}</$name>";
        }
    }

    Tag.new(:$value);
}

