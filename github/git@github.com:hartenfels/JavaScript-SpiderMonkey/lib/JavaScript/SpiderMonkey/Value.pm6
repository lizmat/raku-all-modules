unit class JavaScript::SpiderMonkey::Value is repr('CPointer');
use NativeCall;
use JavaScript::SpiderMonkey::Error;


constant \Error := JavaScript::SpiderMonkey::Error;
constant \Value := JavaScript::SpiderMonkey::Value;


subset Identifier of Str where /^ [<:L>||<[\_\$]>] [<:L>||<[\_\$ 0..9]>]* $/;


sub p6sm_value_context(Value --> OpaquePointer)
    is native('libp6-spidermonkey') { * }

sub p6sm_new_bool_value(OpaquePointer, int32 --> Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_new_num_value(OpaquePointer, num64 --> Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_new_str_value(OpaquePointer, Buf, uint32 --> Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_free(Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_error(Value --> Error)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_type(Value --> Str)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_str(Value --> Str)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_num(Value, num64 is rw --> int32)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_bool(Value, int32 is rw --> int32)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_call(Value, Value, uint32, CArray[OpaquePointer] --> Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_accessible(Value --> int32)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_at_key(Value, Buf, uint32 --> Value)
    is native('libp6-spidermonkey') { * }

sub p6sm_value_at_pos(Value, uint32 --> Value)
    is native('libp6-spidermonkey') { * }


sub enc(Str $s)
{
    my $b = $s.encode('UTF-16');
    return $b, $b.elems;
}


class Object
{
    has Value $.js-val;

    multi method new(Value:D $js-val) { self.bless(:$js-val) }


    method AT-KEY(Object:D: $key)
    {
        my $v = p6sm_value_at_key($!js-val, |enc(~$key)) // fail $!js-val.error;
        return $v.to-perl;
    }

    method AT-POS(Object:D: $key)
    {
        my $v = p6sm_value_at_pos($!js-val, +$key) // fail $!js-val.error;
        return $v.to-perl;
    }


    method CALL-ME(Object:D: *@args, Object:D :$this = self)
    {
        my OpaquePointer:D       $context = p6sm_value_context($!js-val);
        my CArray[OpaquePointer] $values .= new;

        for kv @args -> $i, $arg { $values[$i] = to-value($context, $arg) }

        my $v = p6sm_value_call($!js-val, $this.js-val, @args.elems, $values)
                // fail $!js-val.error;
        return $v.to-perl;
    }

    method call-func(Object:D: Str $method, *@args)
    {
        my $val = self{$method};
        given $val.js-val.type
        {
            fail   "No such method: '$method'" when 'undefined'; # TODO NoSuchMethodError?
            return $val(|@args, :this(self))   when 'function';
            fail   "Can't call a value of type '$_'"; # TODO TypeError?
        }
    }

    method FALLBACK(Object:D: Identifier $method, *@args)
    {
        return self.call-func($method, @args);
    }

}


our proto sub convert($v --> Value:D) { * }

multi sub convert(  Value:D $v) { $v        }
multi sub convert( Object:D $v) { $v.js-val }
multi sub convert(   Bool:D $v) { $v        }
multi sub convert(Stringy:D $v) { $v        }
multi sub convert(Numeric:D $v) { $v        }

sub to-value(OpaquePointer $context, $arg)
{
    given convert($arg)
    {
        when   Value:D { $_ }
        when    Bool:D { p6sm_new_bool_value($context, $_ ?? 1 !! 0) }
        when Numeric:D { p6sm_new_num_value($context, .Num) }
        when Stringy:D { p6sm_new_str_value($context, |enc(.Str)) }
        default        { !!! }
    }
}


method error()
{
    return p6sm_value_error(self).to-exception;
}


method type(Value:D: --> Str)
{
    return p6sm_value_type(self);
}

method Str(Value:D: --> Str)
{
    return p6sm_value_str(self);
}

method Num(Value:D: --> Num)
{
    my num64 $number;
    return $number if p6sm_value_num(self, $number);
    fail self.error;
}

method Bool(Value:D: --> Bool)
{
    my int32 $bool;
    return ?$bool if p6sm_value_bool(self, $bool);
    fail self.error;
}

method to-perl(Value:D:)
{
    given self.type
    {
        return Value              when 'undefined';
        return self.Str           when 'string';
        return self.Num           when 'number';
        return self.Bool          when 'boolean';
      # return Function.new(self) when 'function';
        return   Object.new(self);
    }
}


method DESTROY
{
    p6sm_value_free(self);
}
