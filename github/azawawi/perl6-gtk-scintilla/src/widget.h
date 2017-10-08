#ifndef __WIDGET__

#define WIDGET

#define GTK 1

#include <gtk/gtk.h>
#include <Scintilla.h>
#include <SciLexer.h>
#include <ScintillaWidget.h>

extern GtkWidget* gtk_scintilla_new();

extern void gtk_scintilla_set_id(
    ScintillaObject* sci,
    uptr_t           id);

extern sptr_t gtk_scintilla_send_message(
    ScintillaObject* sci,
    unsigned int     iMessage,
    uptr_t           wParam,
    sptr_t           lParam);

#endif
