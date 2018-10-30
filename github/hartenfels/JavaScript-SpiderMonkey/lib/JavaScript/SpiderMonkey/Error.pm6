unit class JavaScript::SpiderMonkey::Error is repr('CPointer');
use NativeCall;


constant \Error := JavaScript::SpiderMonkey::Error;


class X::JavaScript::SpiderMonkey is Exception
{
    has Str   $.message;
    has Str   $.file;
    has int32 $.line;
    has int32 $.column;

    method Str()  { "$.message in '$.file' at $.line:$.column" }
    method gist() { ~self }
}


sub p6sm_error_message(Error --> Str  ) is native('libp6-spidermonkey') { * }
sub p6sm_error_file   (Error --> Str  ) is native('libp6-spidermonkey') { * }
sub p6sm_error_line   (Error --> int32) is native('libp6-spidermonkey') { * }
sub p6sm_error_column (Error --> int32) is native('libp6-spidermonkey') { * }

method to-exception()
{
    die "Internal error: there's no error to throw!" without self;
    return X::JavaScript::SpiderMonkey.new(
        message => p6sm_error_message(self),
        file    => p6sm_error_file(self),
        line    => p6sm_error_line(self),
        column  => p6sm_error_column(self),
    );
}
