use JSON::Name;

unit module JSON::Unmarshal;
use JSON::Fast;

role CustomUnmarshaller {
    method unmarshal($value, Mu:U $type) {
        ...
    }
}

role CustomUnmarshallerCode does CustomUnmarshaller {
    has &.unmarshaller is rw;

    method unmarshal($value, Mu:U $type) {
        # the dot below is important otherwise it refers
        # to the accessor method
        self.unmarshaller.($value);
    }
}

role CustomUnmarshallerMethod does CustomUnmarshaller {
    has Str $.unmarshaller is rw;
    method unmarshal($value, Mu:U $type) {
        my $meth = self.unmarshaller;
        $type."$meth"($value);
    }
}

multi sub trait_mod:<is> (Attribute $attr, :&unmarshalled-by!) is export {
    $attr does CustomUnmarshallerCode;
    $attr.unmarshaller = &unmarshalled-by;
}

multi sub trait_mod:<is> (Attribute $attr, Str:D :$unmarshalled-by!) is export {
    $attr does CustomUnmarshallerMethod;
    $attr.unmarshaller = $unmarshalled-by;
}

sub panic($json, $type) {
    die "Cannot unmarshal {$json.perl} to type {$type.perl}"
}

multi _unmarshal(Any:U, Mu $type) {
    $type;
}

multi _unmarshal(Any:D $json, Int) {
    if $json ~~ Int {
        return Int($json)
    }
    panic($json, Int)
}

multi _unmarshal(Any:D $json, Rat) {
   CATCH {
      default {
         panic($json, Rat);
      }
   }
   return Rat($json);
}

multi _unmarshal(Any:D $json, Numeric) {
    if $json ~~ Numeric {
        return Num($json)
    }
    panic($json, Numeric)
}

multi _unmarshal($json, Str) {
    if $json ~~ Stringy {
        return Str($json)
    }
    else {
        Str;
    }
}

multi _unmarshal(Any:D $json, Bool) {
   CATCH {
      default {
         panic($json, Bool);
      }
   }
   return Bool($json);
}

multi _unmarshal(Any:D $json, Any $x) {
    my %args;
    my %local-attrs =  $x.^attributes(:local).map({ $_.name => $_.package });
    for $x.^attributes -> $attr {
        if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package ) {
            next;
        }
        my $attr-name = $attr.name.substr(2);
        my $json-name = do if  $attr ~~ JSON::Name::NamedAttribute {
            $attr.json-name;
        }
        else {
            $attr-name;
        }
        if $json{$json-name}:exists {
            %args{$attr-name} := do if $attr ~~ CustomUnmarshaller {
                $attr.unmarshal($json{$json-name}, $attr.type);
            }
            else {
                _unmarshal($json{$json-name}, $attr.type);
            }
        }
    }
    return $x.new(|%args)
}

multi _unmarshal($json, @x) {
    my @ret;
    for $json.list -> $value {
       my $type = @x.of =:= Any ?? $value.WHAT !! @x.of;
       @ret.append(_unmarshal($value, $type));
    }
    return @ret;
}

multi _unmarshal($json, %x) {
   my %ret;
   for $json.kv -> $key, $value {
      my $type = %x.of =:= Any ?? $value.WHAT !! %x.of;
      %ret{$key} = _unmarshal($value, $type);
   }
   return %ret;
}

multi _unmarshal(Any:D $json, Mu) {
    return $json
}

multi unmarshal($json, Positional $obj) is export {
    my Any \data = from-json($json);
    if data ~~ Positional {
        return @(_unmarshal($_, $obj.of) for @(data));
    } else {
        fail "Unmarshaling to type $obj.^name() requires the json data to be a list of objects.";
    }
}

multi unmarshal($json, Associative $obj) is export {
    my \data = from-json($json);
    if data ~~ Associative {
        return %(for data.kv -> $key, $value {
            $key => _unmarshal($value, $obj.of)
        })
    } else {
        fail "Unmarshaling to type $obj.^name() requires the json data to be an object.";
    };
}

multi unmarshal($json, $obj) is export {
    _unmarshal(from-json($json), $obj)
}
# vim: expandtab shiftwidth=4 ft=perl6
