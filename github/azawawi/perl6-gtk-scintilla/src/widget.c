
#include "widget.h"

#include <Scintilla.h>
#include <SciLexer.h>
#include <ScintillaWidget.h>

GtkWidget* gtk_scintilla_new() {
    return scintilla_new();
}

void gtk_scintilla_set_id(
  ScintillaObject* sci,
  uptr_t           id)
{
    scintilla_set_id(sci, id);
}

sptr_t gtk_scintilla_send_message(
  ScintillaObject* sci,
  unsigned int     iMessage,
  uptr_t           wParam,
  sptr_t           lParam)
{
    return scintilla_send_message(sci, iMessage, wParam, lParam);
}
