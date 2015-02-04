use NativeCall;

sub MessageBoxA(int32, Str, Str, int32)
    returns int32
    is native('user32')
    { * }

MessageBoxA(0, "We can haz NCI?", "oh lol", 64);
