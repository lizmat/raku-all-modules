
use v6;

unit module GTK::Scintilla::Raw;

use NativeCall;

sub library {
    return ~%?RESOURCES{"libwidget.so"};
}

sub gtk_scintilla_new returns Pointer is native(&library) is export { * }

sub gtk_scintilla_set_id(Pointer $sci, int32 $id)
    is native(&library)
    is export
    { * }
    
sub gtk_scintilla_send_message(Pointer $sci, uint32 $iMessage, int32 $wParam, int32 $lParam)
    returns uint32
    is native(&library)
    is export
    { * }

sub gtk_scintilla_send_message_str(Pointer $sci, uint32 $iMessage, int32 $wParam, Str $lParam)
    returns Pointer
    is native(&library)
    is symbol('gtk_scintilla_send_message')
    is export
    { * }
