#include <gtk/gtk.h>

/* https://prognotes.net/2015/06/gtk-3-c-program-using-glade-3/

   gcc -o ex ex.c -Wall `pkg-config --cflags --libs gtk+-3.0` -export-dynamic
*/
int main( int argc, char *argv[]) {

  GtkBuilder      *builder;
  GtkWidget       *window;

  gtk_init( &argc, &argv);

  builder = gtk_builder_new();
  gtk_builder_add_from_file ( builder, "ex.glade", NULL);

  window = GTK_WIDGET( gtk_builder_get_object( builder, "window_main"));
  gtk_builder_connect_signals( builder, NULL);

  g_object_unref(builder);

  gtk_widget_show(window);
  gtk_main();

  return 0;
}

// called when window is closed
void on_window_main_destroy() {
  gtk_main_quit();
}
