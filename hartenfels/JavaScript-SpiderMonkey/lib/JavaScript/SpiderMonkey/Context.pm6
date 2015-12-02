unit class JavaScript::SpiderMonkey::Context is repr('CPointer');
use NativeCall;
use JavaScript::SpiderMonkey::Error;
use JavaScript::SpiderMonkey::Runtime;
use JavaScript::SpiderMonkey::Value;


constant \Error   := JavaScript::SpiderMonkey::Error;
constant \Value   := JavaScript::SpiderMonkey::Value;
constant \Context := JavaScript::SpiderMonkey::Context;
constant \Runtime := JavaScript::SpiderMonkey::Runtime;


sub p6sm_context_new(Runtime, int32 --> Context)
    is native('libp6-spidermonkey') { * }

sub p6sm_context_free(Context)
    is native('libp6-spidermonkey') { * }

sub p6sm_context_error(Context --> Error)
    is native('libp6-spidermonkey') { * }

sub p6sm_context_eval(Context, Buf, uint32, Str, int32 --> Value)
    is native('libp6-spidermonkey') { * }


method new(Runtime:D $rt, int32 $stack_size = 8192 --> Context:D)
{
    return p6sm_context_new($rt, $stack_size);
}


method error()
{
    return p6sm_context_error(self).to-exception;
}


method eval(Context:D: Str   $code,
                       Str   $file = 'eval',
                       int32 $line = 1)
{
    my $b = $code.encode('UTF-16');
    my $v = p6sm_context_eval(self, $b, $b.elems, $file, $line)
         // fail self.error;
    return $v.to-perl;
}

method do(Context:D: Cool $path)
{
    return self.eval(slurp($path), $path);
}


method DESTROY
{
    p6sm_context_free(self);
}
