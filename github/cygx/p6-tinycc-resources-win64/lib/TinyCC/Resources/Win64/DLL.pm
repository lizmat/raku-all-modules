my constant DLL = $*VM.config<prefix>.IO.child('bin/libtcc.dll');
class TinyCC::Resources::Win64::DLL {
    method path { DLL }
    method setenv { %*ENV<LIBTCC> = ~DLL }
}
