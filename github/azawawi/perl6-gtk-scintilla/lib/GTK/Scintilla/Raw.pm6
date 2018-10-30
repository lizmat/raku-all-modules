
use v6;

use NativeCall;

unit module GTK::Scintilla::Raw;

sub library {
    return ~%?RESOURCES{"libwidget.so"};
}

sub gtk_scintilla_new returns Pointer is native(&library) is export { * }

sub gtk_scintilla_set_id(Pointer $sci, int32 $id)
    is native(&library)
    is export
    { * }
    
sub gtk_scintilla_send_message(Pointer $sci, uint32 $iMessage, int32 $wParam,
    int32 $lParam)
    returns int32
    is native(&library)
    is export
    { * }

sub gtk_scintilla_send_message_str(Pointer $sci, uint32 $iMessage,
    int32 $wParam, Str $lParam)
    returns int32
    is native(&library)
    is symbol('gtk_scintilla_send_message')
    is export
    { * }

sub gtk_scintilla_send_message_carray(Pointer $sci, uint32 $iMessage,
    int32 $wParam, CArray[uint8] $lParam)
    returns int32
    is native(&library)
    is symbol('gtk_scintilla_send_message')
    is export
    { * }
