unit class JavaScript::SpiderMonkey::Runtime is repr('CPointer');
use NativeCall;


constant \Runtime := JavaScript::SpiderMonkey::Runtime;


sub p6sm_runtime_new(long --> Runtime)
    is native('libp6-spidermonkey') { * }

sub p6sm_runtime_free(Runtime)
    is native('libp6-spidermonkey') { * }


method new(long $memory = 8 * 1024 ** 2 --> Runtime:D)
{
    return p6sm_runtime_new($memory):
}

method DESTROY
{
    p6sm_runtime_free(self);
}
