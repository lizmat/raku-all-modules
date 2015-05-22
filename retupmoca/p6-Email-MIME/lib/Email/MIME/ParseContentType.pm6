unit role Email::MIME::ParseContentType;

grammar ContentTypeHeader {
    token TOP {
        ^ <type> \/ <subtype> \s* <params>? $
    }
    token type {
        \w+
    }
    token subtype {
        \w+
    }
    token params {
        [\; \s* <param>]* \s*
    }
    token param {
        <name> \= \"?<value>\"?
    }
    token name {
        \w+
    }
    token value {
        <-[\s";]>+
    }
}

method parse-content-type (Str $content-type) {
    my $ct-default = 'text/plain; charset=us-ascii';
    
    unless $content-type && $content-type.chars {
        return self.parse-content-type($ct-default);
    }
    
    my $result;
    
    try {
        my $parsed = ContentTypeHeader.parse($content-type);
        
        $result<type> = ~$parsed<type>;
        $result<subtype> = ~$parsed<subtype>;
        
        my @entries = $parsed<params><param>.list;
        for @entries {
            $result<attributes>{~$_<name>} = ~$_<value>;
        }
        
        CATCH {
            default {
                $result = self.parse-content-type($ct-default);
            }
        }
    }
    
    return $result;
}

method parse-header-attributes (Str $attributestring) {
    my $parsed = ContentTypeHeader.parse($attributestring, rule => 'params');

    my $params;

    for $parsed<param>.list {
        $params{~$_<name>} = ~$_<value>;
    }

    return $params;
}
