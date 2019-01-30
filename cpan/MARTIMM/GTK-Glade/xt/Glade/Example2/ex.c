
/* Translate with
   gcc -o ex ex.c `pkg-config --cflags --libs gtk+-3.0`
*/

#include <gtk/gtk.h>

//------------------------------------------------------------------------------
static void print_hello ( GtkWidget *widget, gpointer data ) {
  g_print("Hello World\n");
}

//------------------------------------------------------------------------------
int main ( int argc, char *argv[] ) {

  GtkBuilder *builder;
  GObject *window;
  GObject *button;

  gtk_init( &argc, &argv);

  /* Construct a GtkBuilder instance and load our UI description */
  builder = gtk_builder_new();
  gtk_builder_add_from_file( builder, "ex.ui", NULL);

  /* Connect signal handlers to the constructed widgets. */
  window = gtk_builder_get_object( builder, "window");
  g_signal_connect( window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

  button = gtk_builder_get_object( builder, "button1");
  g_signal_connect( button, "clicked", G_CALLBACK(print_hello), NULL);

  button = gtk_builder_get_object( builder, "button2");
  g_signal_connect( button, "clicked", G_CALLBACK(print_hello), NULL);

/*
  button = gtk_builder_get_object( builder, "quit");
  //g_signal_connect( button, "clicked", G_CALLBACK(gtk_main_quit), NULL);
  g_signal_connect_object( button, "clicked", G_CALLBACK(gtk_main_quit), NULL, G_SIGNAL_RUN_FIRST);
*/
  // Connections are not made automatically which is nice
  gtk_builder_connect_signals( builder, NULL);
  gtk_main();

  return 0;
}
