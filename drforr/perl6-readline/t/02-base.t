use v6;

use Test;

plan 41;

use Readline;

constant UNSIGNED-MINUS-ONE = 4294967295; # XXX Remove when unsigned works

##############################################################################
#
# /* A static variable for holding the line. */
# static char *line_read = (char *)NULL;
# 
# /* Read a string, and return a pointer to it.
#    Returns NULL on EOF. */
# char *
# rl_gets ()
# {
#   /* If the buffer has already been allocated,
#      return the memory to the free pool. */
#   if (line_read)
#     {
#       free (line_read);
#       line_read = (char *)NULL;
#     }
# 
#   /* Get a line from the user. */
#   line_read = readline ("");
# 
#   /* If the line has any text in it,
#      save it on the history. */
#   if (line_read && *line_read)
#     add_history (line_read);
# 
#   return (line_read);
# }
# 
##############################################################################

##############################################################################
#
# /* Invert the case of the COUNT following characters. */
# int
# invert_case_line (count, key)
#      int count, key;
# {
#   register int start, end, i;
# 
#   start = rl_point;
# 
#   if (rl_point >= rl_end)
#     return (0);
# 
#   if (count < 0)
#     {
#       direction = -1;
#       count = -count;
#     }
#   else
#     direction = 1;
#       
#   /* Find the end of the range to modify. */
#   end = start + (count * direction);
# 
#   /* Force it to be within range. */
#   if (end > rl_end)
#     end = rl_end;
#   else if (end < 0)
#     end = 0;
# 
#   if (start == end)
#     return (0);
# 
#   if (start > end)
#     {
#       int temp = start;
#       start = end;
#       end = temp;
#     }
# 
#   /* Tell readline that we are modifying the line,
#      so it will save the undo information. */
#   rl_modifying (start, end);
# 
#   for (i = start; i != end; i++)
#     {
#       if (_rl_uppercase_p (rl_line_buffer[i]))
#         rl_line_buffer[i] = _rl_to_lower (rl_line_buffer[i]);
#       else if (_rl_lowercase_p (rl_line_buffer[i]))
#         rl_line_buffer[i] = _rl_to_upper (rl_line_buffer[i]);
#     }
#   /* Move point to on top of the last character changed. */
#   rl_point = (direction == 1) ? end - 1 : start;
#   return (0);
# }
# 
#############################################################################

#############################################################################
# 
# static void cb_linehandler (char *);
# 
# int running;
# const char *prompt = "rltest$ ";
# 
# /* Callback function called for each line when accept-line executed, EOF
#    seen, or EOF character read.  This sets a flag and returns; it could
#    also call exit(3). */
# static void
# cb_linehandler (char *line)
# {
#   /* Can use ^D (stty eof) or `exit' to exit. */
#   if (line == NULL || strcmp (line, "exit") == 0)
#     {
#       if (line == 0)
#         printf ("\n");
#       printf ("exit\n");
#       /* This function needs to be called to reset the terminal settings,
#          and calling it from the line handler keeps one extra prompt from
#          being displayed. */
#       rl_callback_handler_remove ();
# 
#       running = 0;
#     }
#   else
#     {
#       if (*line)
#         add_history (line);
#       printf ("input line: %s\n", line);
#       free (line);
#     }
# }
# 
# int
# main (int c, char **v)
# {
#   fd_set fds;
#   int r;
# 
#   /* Install the line handler. */
#   rl_callback_handler_install (prompt, cb_linehandler);
# 
#   /* Enter a simple event loop.  This waits until something is available
#      to read on readline's input stream (defaults to standard input) and
#      calls the builtin character read callback to read it.  It does not
#      have to modify the user's terminal settings. */
#   running = 1;
#   while (running)
#     {
#       FD_ZERO (&fds);
#       FD_SET (fileno (rl_instream), &fds);    
# 
#       r = select (FD_SETSIZE, &fds, NULL, NULL, NULL);
#       if (r < 0)
#         {
#           perror ("rltest: select");
#           rl_callback_handler_remove ();
#           break;
#         }
# 
#       if (FD_ISSET (fileno (rl_instream), &fds))
#         rl_callback_read_char ();
#     }
# 
#   printf ("rltest: Event loop has exited\n");
#   return 0;
# }
# 
#############################################################################

#/* fileman.c -- A tiny application which demonstrates how to use the
#   GNU Readline library.  This application interactively allows users
#   to manipulate files and their modes. */
#
##ifdef HAVE_CONFIG_H
##  include <config.h>
##endif
#
##include <sys/types.h>
##ifdef HAVE_SYS_FILE_H
##  include <sys/file.h>
##endif
##include <sys/stat.h>
#
##ifdef HAVE_UNISTD_H
##  include <unistd.h>
##endif
#
##include <fcntl.h>
##include <stdio.h>
##include <errno.h>
#
##if defined (HAVE_STRING_H)
##  include <string.h>
##else /* !HAVE_STRING_H */
##  include <strings.h>
##endif /* !HAVE_STRING_H */
#
##ifdef HAVE_STDLIB_H
##  include <stdlib.h>
##endif
#
##include <time.h>
#
##include <readline/readline.h>
##include <readline/history.h>
#
#extern char *xmalloc PARAMS((size_t));
#
#/* The names of functions that actually do the manipulation. */
#int com_list PARAMS((char *));
#int com_view PARAMS((char *));
#int com_rename PARAMS((char *));
#int com_stat PARAMS((char *));
#int com_pwd PARAMS((char *));
#int com_delete PARAMS((char *));
#int com_help PARAMS((char *));
#int com_cd PARAMS((char *));
#int com_quit PARAMS((char *));
#
#/* A structure which contains information on the commands this program
#   can understand. */
#
#typedef struct {
#  char *name;			/* User printable name of the function. */
#  rl_icpfunc_t *func;		/* Function to call to do the job. */
#  char *doc;			/* Documentation for this function.  */
#} COMMAND;
#
#COMMAND commands[] = {
#  { "cd", com_cd, "Change to directory DIR" },
#  { "delete", com_delete, "Delete FILE" },
#  { "help", com_help, "Display this text" },
#  { "?", com_help, "Synonym for `help'" },
#  { "list", com_list, "List files in DIR" },
#  { "ls", com_list, "Synonym for `list'" },
#  { "pwd", com_pwd, "Print the current working directory" },
#  { "quit", com_quit, "Quit using Fileman" },
#  { "rename", com_rename, "Rename FILE to NEWNAME" },
#  { "stat", com_stat, "Print out statistics on FILE" },
#  { "view", com_view, "View the contents of FILE" },
#  { (char *)NULL, (rl_icpfunc_t *)NULL, (char *)NULL }
#};
#
#/* Forward declarations. */
#char *stripwhite ();
#COMMAND *find_command ();
#
#/* The name of this program, as taken from argv[0]. */
#char *progname;
#
#/* When non-zero, this global means the user is done using this program. */
#int done;
#
#char *
#dupstr (s)
#     char *s;
#{
#  char *r;
#
#  r = xmalloc (strlen (s) + 1);
#  strcpy (r, s);
#  return (r);
#}
#
#main (argc, argv)
#     int argc;
#     char **argv;
#{
#  char *line, *s;
#
#  progname = argv[0];
#
#  initialize_readline ();	/* Bind our completer. */
#
#  /* Loop reading and executing lines until the user quits. */
#  for ( ; done == 0; )
#    {
#      line = readline ("FileMan: ");
#
#      if (!line)
#        break;
#
#      /* Remove leading and trailing whitespace from the line.
#         Then, if there is anything left, add it to the history list
#         and execute it. */
#      s = stripwhite (line);
#
#      if (*s)
#        {
#          add_history (s);
#          execute_line (s);
#        }
#
#      free (line);
#    }
#  exit (0);
#}
#
#/* Execute a command line. */
#int
#execute_line (line)
#     char *line;
#{
#  register int i;
#  COMMAND *command;
#  char *word;
#
#  /* Isolate the command word. */
#  i = 0;
#  while (line[i] && whitespace (line[i]))
#    i++;
#  word = line + i;
#
#  while (line[i] && !whitespace (line[i]))
#    i++;
#
#  if (line[i])
#    line[i++] = '\0';
#
#  command = find_command (word);
#
#  if (!command)
#    {
#      fprintf (stderr, "%s: No such command for FileMan.\n", word);
#      return (-1);
#    }
#
#  /* Get argument to command, if any. */
#  while (whitespace (line[i]))
#    i++;
#
#  word = line + i;
#
#  /* Call the function. */
#  return ((*(command->func)) (word));
#}
#
#/* Look up NAME as the name of a command, and return a pointer to that
#   command.  Return a NULL pointer if NAME isn't a command name. */
#COMMAND *
#find_command (name)
#     char *name;
#{
#  register int i;
#
#  for (i = 0; commands[i].name; i++)
#    if (strcmp (name, commands[i].name) == 0)
#      return (&commands[i]);
#
#  return ((COMMAND *)NULL);
#}
#
#/* Strip whitespace from the start and end of STRING.  Return a pointer
#   into STRING. */
#char *
#stripwhite (string)
#     char *string;
#{
#  register char *s, *t;
#
#  for (s = string; whitespace (*s); s++)
#    ;
#    
#  if (*s == 0)
#    return (s);
#
#  t = s + strlen (s) - 1;
#  while (t > s && whitespace (*t))
#    t--;
#  *++t = '\0';
#
#  return s;
#}
#
#/* **************************************************************** */
#/*                                                                  */
#/*                  Interface to Readline Completion                */
#/*                                                                  */
#/* **************************************************************** */
#
#char *command_generator PARAMS((const char *, int));
#char **fileman_completion PARAMS((const char *, int, int));
#
#/* Tell the GNU Readline library how to complete.  We want to try to complete
#   on command names if this is the first word in the line, or on filenames
#   if not. */
#initialize_readline ()
#{
#  /* Allow conditional parsing of the ~/.inputrc file. */
#  rl_readline_name = "FileMan";
#
#  /* Tell the completer that we want a crack first. */
#  rl_attempted_completion_function = fileman_completion;
#}
#
#/* Attempt to complete on the contents of TEXT.  START and END bound the
#   region of rl_line_buffer that contains the word to complete.  TEXT is
#   the word to complete.  We can use the entire contents of rl_line_buffer
#   in case we want to do some simple parsing.  Return the array of matches,
#   or NULL if there aren't any. */
#char **
#fileman_completion (text, start, end)
#     const char *text;
#     int start, end;
#{
#  char **matches;
#
#  matches = (char **)NULL;
#
#  /* If this word is at the start of the line, then it is a command
#     to complete.  Otherwise it is the name of a file in the current
#     directory. */
#  if (start == 0)
#    matches = rl_completion_matches (text, command_generator);
#
#  return (matches);
#}
#
#/* Generator function for command completion.  STATE lets us know whether
#   to start from scratch; without any state (i.e. STATE == 0), then we
#   start at the top of the list. */
#char *
#command_generator (text, state)
#     const char *text;
#     int state;
#{
#  static int list_index, len;
#  char *name;
#
#  /* If this is a new word to complete, initialize now.  This includes
#     saving the length of TEXT for efficiency, and initializing the index
#     variable to 0. */
#  if (!state)
#    {
#      list_index = 0;
#      len = strlen (text);
#    }
#
#  /* Return the next name which partially matches from the command list. */
#  while (name = commands[list_index].name)
#    {
#      list_index++;
#
#      if (strncmp (name, text, len) == 0)
#        return (dupstr(name));
#    }
#
#  /* If no names matched, then return NULL. */
#  return ((char *)NULL);
#}
#
#/* **************************************************************** */
#/*                                                                  */
#/*                       FileMan Commands                           */
#/*                                                                  */
#/* **************************************************************** */
#
#/* String to pass to system ().  This is for the LIST, VIEW and RENAME
#   commands. */
#static char syscom[1024];
#
#/* List the file(s) named in arg. */
#com_list (arg)
#     char *arg;
#{
#  if (!arg)
#    arg = "";
#
#  sprintf (syscom, "ls -FClg %s", arg);
#  return (system (syscom));
#}
#
#com_view (arg)
#     char *arg;
#{
#  if (!valid_argument ("view", arg))
#    return 1;
#
##if defined (__MSDOS__)
#  /* more.com doesn't grok slashes in pathnames */
#  sprintf (syscom, "less %s", arg);
##else
#  sprintf (syscom, "more %s", arg);
##endif
#  return (system (syscom));
#}
#
#com_rename (arg)
#     char *arg;
#{
#  too_dangerous ("rename");
#  return (1);
#}
#
#com_stat (arg)
#     char *arg;
#{
#  struct stat finfo;
#
#  if (!valid_argument ("stat", arg))
#    return (1);
#
#  if (stat (arg, &finfo) == -1)
#    {
#      perror (arg);
#      return (1);
#    }
#
#  printf ("Statistics for `%s':\n", arg);
#
#  printf ("%s has %d link%s, and is %d byte%s in length.\n",
#	  arg,
#          finfo.st_nlink,
#          (finfo.st_nlink == 1) ? "" : "s",
#          finfo.st_size,
#          (finfo.st_size == 1) ? "" : "s");
#  printf ("Inode Last Change at: %s", ctime (&finfo.st_ctime));
#  printf ("      Last access at: %s", ctime (&finfo.st_atime));
#  printf ("    Last modified at: %s", ctime (&finfo.st_mtime));
#  return (0);
#}
#
#com_delete (arg)
#     char *arg;
#{
#  too_dangerous ("delete");
#  return (1);
#}
#
#/* Print out help for ARG, or for all of the commands if ARG is
#   not present. */
#com_help (arg)
#     char *arg;
#{
#  register int i;
#  int printed = 0;
#
#  for (i = 0; commands[i].name; i++)
#    {
#      if (!*arg || (strcmp (arg, commands[i].name) == 0))
#        {
#          printf ("%s\t\t%s.\n", commands[i].name, commands[i].doc);
#          printed++;
#        }
#    }
#
#  if (!printed)
#    {
#      printf ("No commands match `%s'.  Possibilties are:\n", arg);
#
#      for (i = 0; commands[i].name; i++)
#        {
#          /* Print in six columns. */
#          if (printed == 6)
#            {
#              printed = 0;
#              printf ("\n");
#            }
#
#          printf ("%s\t", commands[i].name);
#          printed++;
#        }
#
#      if (printed)
#        printf ("\n");
#    }
#  return (0);
#}
#
#/* Change to the directory ARG. */
#com_cd (arg)
#     char *arg;
#{
#  if (chdir (arg) == -1)
#    {
#      perror (arg);
#      return 1;
#    }
#
#  com_pwd ("");
#  return (0);
#}
#
#/* Print out the current working directory. */
#com_pwd (ignore)
#     char *ignore;
#{
#  char dir[1024], *s;
#
#  s = getcwd (dir, sizeof(dir) - 1);
#  if (s == 0)
#    {
#      printf ("Error getting pwd: %s\n", dir);
#      return 1;
#    }
#
#  printf ("Current directory is %s\n", dir);
#  return 0;
#}
#
#/* The user wishes to quit using this program.  Just set DONE non-zero. */
#com_quit (arg)
#     char *arg;
#{
#  done = 1;
#  return (0);
#}
#
#/* Function which tells you that you can't do this. */
#too_dangerous (caller)
#     char *caller;
#{
#  fprintf (stderr,
#           "%s: Too dangerous for me to distribute.  Write it yourself.\n",
#           caller);
#}
#
#/* Return non-zero if ARG is a valid argument for CALLER, else print
#   an error message and return zero. */
#int
#valid_argument (caller, arg)
#     char *caller, *arg;
#{
#  if (!arg || !*arg)
#    {
#      fprintf (stderr, "%s: Argument required.\n", caller);
#      return (0);
#    }
#
#  return (1);
#}
#
#############################################################################

my $r = Readline.new;

my $history-state;
my $history-entry;
my $histdata-t;
my $time-t;
my $size;
my $map;
my $readline-state;

### 
### =item readline( Str $prompt ) returns Str
### 

### 
### =item rl-initialize( ) returns Int
### 

### 
### =item rl-ding( ) returns Int
### 

subtest sub {
  lives_ok { $r.using-history },
           'using-history lives';
  lives_ok { $r.add-history( 'foo' ) },
           'add-history lives';
  lives_ok { $history-state = $r.history-get-history-state() },
           'history-get-history-state lives';
  lives_ok { $r.history-set-history-state( $history-state ) },
           'history-set-history-state lives';
  lives_ok { $r.add-history-time( '2015-01-01 10:00:00' ) },
           'add-history lives';
  lives_ok { $history-state = $r.remove-history( 0 ) },
           'remove-history';
  lives_ok { $histdata-t = $r.free-history-entry( $history-state ) },
           'free-history-entry';
  lives_ok { $history-state =
               $r.replace-history-entry( 0, 'bar', $histdata-t ) },
           'remove-history';
  lives_ok { $r.clear-history },
           'clear-history lives';
  subtest sub {
    nok $r.history-is-stifled,
        'history-is-stifled is false';
    lives_ok { $r.stifle-history( 0 ) },
             'stifle-history lives';
    ok $r.history-is-stifled,
       'history-is-stifled is false';
    lives_ok { $r.unstifle-history },
             'unstifle-history lives';
    lives_ok { $r.history-is-stifled },
             'history-is-stifled lives';
    nok $r.history-is-stifled,
        'history-is-stifled is false';
  }, 'Stifling';
  lives_ok { $r.history-list },
           'history-list lives'; # XXX We can check this further.
  lives_ok { $r.where-history },
           'where-history lives';
  is $r.where-history, 0, 'where-history returns correctly';
  lives_ok { $r.current-history( 0 ) },
           'current-history lives';
  lives_ok { $r.history-get( 0 ) },
           'history-get lives';
#  lives_ok { $time-t = $r.history-get-time( $history-entry ) },
#           'history-get-time lives';
  lives_ok { $size = $r.history-total-bytes },
           'history-total-bytes lives';
  lives_ok { my $pos = $r.history-set-pos( 0 ) },
           'history-set-pos lives';
  lives_ok { $history-entry = $r.previous-history },
           'previous-history lives';
  lives_ok { $history-entry = $r.next-history },
           'next-history lives';
  lives_ok { my $pos = $r.history-search( 'foo', 0 ) },
           'history-search lives';
  lives_ok { my $pos = $r.history-search-prefix( 'foo', 0 ) },
           'history-search-prefix lives';
  lives_ok { my $pos = $r.history-search-pos( 'foo', 0, 0 ) },
           'history-search-pos lives';
  lives_ok { my $items = $r.read-history( 'foo' ) },
           'read-history lives';
  lives_ok { my $items = $r.read-history-range( 'foo', 0, 1 ) },
           'read-history-range lives';
#  lives_ok { my $result = $r.write-history( 'foo' ) }, # XXX test 'write'? No.
#           'write-history lives';
#  lives_ok { my $result = $r.append-history( 0, 'foo' ) }, # XXX test 'write'? No.
#           'append-history lives';
#  lives_ok { my $items = $r.history-truncate-file( 'foo', 0 ) }, # XXX test truncate? Not yet.
#           'history-truncate-file lives';
#  lives_ok { my $value; my $res = $r.history-expand( 'foo', \$value ) }, # XXX test truncate? Not yet. # XXX wrap it properly
#           'history-expand lives';
  lives_ok { my $res = $r.history-arg-extract( 0, 2, 'foo' ) },
           'history-arg-extract lives';
#  lives_ok { my $index; my $res = $r.get-history-event( 'foo', \$index, "'" ) }, # XXX Wrap it properly
#           'get-history-event lives';
#  lives_ok { my @str = $r.history-tokenize( 'foo' ) }, # XXX Type issues
#           'history-tokenize lives';
}, 'History';

subtest sub {
  #my Keymap $map; # XXX expose Keymap in a few revs.
  my $map;
  lives_ok { $map = $r.rl-make-bare-keymap },
           'rl-make-bare-keymap lives';
  lives_ok { $map = $r.rl-copy-keymap( $map ) },
           'rl-copy-keymap lives';
  lives_ok { $map = $r.rl-make-keymap },
           'rl-make-keymap lives';
  lives_ok { $r.rl-discard-keymap( $map ) },
           'rl-discard-keymap lives';
  lives_ok { $r.rl-free-keymap( $map ) },
           'rl-free-keymap lives';
  lives_ok { $map = $r.rl-get-keymap-by-name( 'foo' ) },
           'rl-get-keymap-by-name lives';
  lives_ok { $map = $r.rl-get-keymap },
           'rl-get-keymap lives';
  lives_ok { my $name = $r.rl-get-keymap-name( $map ) },
           'rl-get-keymap-name lives';
  lives_ok { $r.rl-set-keymap( $map ) },
           'rl-set-keymap lives';
}, 'Keymap';

subtest sub {
#  lives_ok { $r.rl-callback-handler-install( 'readline-test$ ', &call-me ) },
#           'rl-callback-handler-install lives';
#  lives_ok { $r.rl-callback-read-char }, # XXX Blocks, of course.
#           'rl-callback-read-char lives';
  lives_ok { $r.rl-callback-handler-remove },
           'rl-callback-handler-remove lives';
}, 'Callback';

subtest sub {
  lives_ok { $r.rl-set-prompt( 'readline-test$ ' ) },
           'rl-set-prompt lives';
  lives_ok { my $rv = $r.rl-expand-prompt( 'readline-test$ ' ) },
           'rl-expand-prompt lives';
}, 'Prompt';

subtest sub {
  my $map;
#  lives_ok { $r.rl-bind-key( 'X', &callback ) },
#           'rl-bind-key lives';
#  lives_ok { my $rv = $r.rl-bind-key-in-map( 'X', &callback, $map ) },
#           'rl-bind-key-in-map lives';
  lives_ok { $r.rl-unbind-key( 'X' ) },
           'rl-unbind-key lives';
#  lives_ok { $r.rl-unbind-key-in-map( 'X', $map ) },
#           'rl-unbind-key-in-map lives';
#  lives_ok { my $rv = $r.rl-bind-key-if-unbound( 'X', &callback ) },
#           'rl-bind-key-if-unbound lives';
#  lives_ok { my $rv = $r.rl-bind-key-if-unbound-in-map( 'X', &callback, $map ) },
#           'rl-bind-key-if-unbound-in-map lives';
#  lives_ok { my $rv = $r.rl-unbind-function-in-map( &callback, $map ) },
#           'rl-unbind-function-in-map lives';
#  lives_ok { my $rv = $r.rl-bind-keyseq( 'X', &callback ) },
#           'rl-bind-keyseq lives';
#  lives_ok { my $rv = $r.rl-bind-keyseq-in-map( 'X', &callback, $map ) },
#           'rl-bind-keyseq-in-map lives';
#  lives_ok { my $rv = $r.rl-bind-keyseq-if-unbound( 'X', &callback ) },
#           'rl-bind-keyseq-if-unbound lives';
#  lives_ok { my $rv = $r.rl-bind-keyseq-if-unbound-in-map( 'X', &callback, $map ) },
#           'rl-bind-keyseq-if-unbound-in-map lives';
#  lives_ok { my $rv = $r.rl-generic-bind( 0, 'X', 'XX', $map ) },
#           'rl-generic-bind lives';
}, 'Binding';

#lives_ok { my $rv = $r.rl-add-defun( 'XX', &callback, 'X' ) },
#         'rl-add-defun lives';
lives_ok { my $rv = $r.rl-variable-value( 'visible-bell' ) },
         'rl-variable-value lives';
lives_ok { my $rv = $r.rl-variable-bind( 'visible-bell', 'on' ) },
         'rl-variable-bind lives';
#lives_ok { my $rv = $r.rl-set-key( 'X', &callback, $map ) },
#         'rl-set-key lives';
#lives_ok { my $rv = $r.rl-macro-bind( 'X', 'XX', $map ) },
#         'rl-macro-bind lives';
#lives_ok { my $rv = $r.rl-named-function( 'XX' ) },
#         'rl-named-function lives';
#lives_ok { my $rv = $r.rl-function-of-keymap( 'XX', $map, \$type ) },
#         'rl-function-of-keymap lives';
#lives_ok { $r.rl-list-funmap-names( ) },
#         'rl-list-funmap-names lives';
#lives_ok { my $cmd;
#           my @rv = $r.rl-invoking-keyseqs-in-map( &callback, \$cmd, $map ) },
#         'rl-invoking-keyseqs-in-map lives';
#lives_ok { my $cmd;
#           my @rv = $r.rl-invoking-keyseqs( &callback, \$cmd ) },
#         'rl-invoking-keyseqs lives';
#lives_ok { my $rv = $r.rl-function-dumper( True ) },
#         'rl-function-dumper lives';
lives_ok { my $rv = $r.rl-macro-dumper( True ) },
         'rl-macro-dumper lives';
#lives_ok { $r.rl-variable-dumper( True ) },
#         'rl-variable-dumper lives';
lives_ok { my $rv = $r.rl-read-init-file( 'filename' ) },
         'rl-read-init-file lives';
lives_ok { my $rv = $r.rl-parse-and-bind( 'XX' ) },
         'rl-parse-and-bind lives';
#lives_ok { my $rv = $r.rl-add-funmap-entry( 'X', &callback ) },
#         'rl-add-funmap-entry lives';
lives_ok { my $rv = $r.rl-funmap-names },
         'rl-funmap-names lives';
lives_ok { my $rv = $r.rl-push-macro-input( 'macro' ) },
         'rl-push-macro-input lives';
lives_ok { my $rv = $r.rl-free-undo-list },
         'rl-free-undo-list lives';
lives_ok { my $rv = $r.rl-do-undo },
         'rl-do-undo lives';
lives_ok { my $rv = $r.rl-begin-undo-group },
         'rl-begin-undo-group lives';
lives_ok { my $rv = $r.rl-end-undo-group },
         'rl-end-undo-group lives';
#lives_ok { my $rv = $r.rl-modifying( 0, 1 ) },
#         'rl-modifying lives';
lives_ok { my $rv = $r.rl-redisplay },
         'rl-redisplay lives';
lives_ok { my $rv = $r.rl-on-new-line },
         'rl-on-new-line lives';
#lives_ok { my $rv = $r.rl-on-new-line-with-prompt },
#         'rl-on-new-line-with-prompt lives';
lives_ok { my $rv = $r.rl-forced-update-display },
         'rl-forced-update-display lives';
lives_ok { my $rv = $r.rl-clear-message },
         'rl-clear-message lives';
lives_ok { my $rv = $r.rl-reset-line-state },
         'rl-reset-line-state lives';
#lives_ok { my $rv = $r.rl-crlf },
#         'rl-crlf lives';
#lives_ok { my $rv = $r.rl-show-char( 'X' ) },
#         'rl-show-char lives';
lives_ok { my $rv = $r.rl-save-prompt },
         'rl-save-prompt lives';
lives_ok { my $rv = $r.rl-restore-prompt },
         'rl-restore-prompt lives';
lives_ok { my $rv = $r.rl-replace-line( 'foo', 0 ) },
         'rl-replace-line lives';
lives_ok { my $rv = $r.rl-insert-text( 'foo' ) },
         'rl-insert-text lives';
lives_ok { my $rv = $r.rl-delete-text( 0, 1 ) },
         'rl-delete-text lives';
lives_ok { my $rv = $r.rl-kill-text( 0, 1 ) },
         'rl-kill-text lives';
lives_ok { my $rv = $r.rl-copy-text( 0, 1 ) },
         'rl-copy-text lives';
lives_ok { my $rv = $r.rl-prep-terminal( 1 ) },
         'rl-prep-terminal lives';
lives_ok { my $rv = $r.rl-deprep-terminal },
         'rl-deprep-terminal lives';
#lives_ok { my $rv = $r.rl-tty-set-default-bindings( $map ) },
#         'rl-tty-set-default-bindings lives';
#lives_ok { my $rv = $r.rl-tty-unset-default-bindings( $map ) },
#         'rl-tty-unset-default-bindings lives';
lives_ok { my $rv = $r.rl-reset-terminal( 'vt100' ) },
         'rl-reset-terminal lives';
#lives_ok { my $rv = $r.rl-foo( $map ) },
#         'rl-foo lives';
#lives_ok { my $rv = $r.rl-resize-terminal },
#         'rl-resize-terminal lives';
lives_ok { my $rv = $r.rl-set-screen-size( 80, 24 ) },
         'rl-set-screen-size lives';
#lives_ok { my ( $rows, $cols );
#           my $rv = $r.rl-get-screen-size( \$rows, \$cols ) },
#         'rl-get-screen-size lives';
#lives_ok { my $rv = $r.rl-reset-screen-size },
#         'rl-reset-screen-size lives';
lives_ok { my $rv = $r.rl-get-termcap( 'vt100' ) },
         'rl-get-termcap lives';
lives_ok { my $rv = $r.rl-extend-line-buffer( 0 ) },
         'rl-extend-line-buffer lives';
lives_ok { my $rv = $r.rl-alphabetic( 'x' ) },
         'rl-alphabetic lives';
#lives_ok { my $rv = $r.rl-free( $mem ) },
#         'rl-free lives';
lives_ok { my $rv = $r.rl-set-signals },
         'rl-set-signals lives';
lives_ok { my $rv = $r.rl-clear-signals },
         'rl-clear-signals lives';
#lives_ok { my $rv = $r.rl-cleanup-after-signal },
#         'rl-cleanup-after-signal lives';
lives_ok { my $rv = $r.rl-reset-after-signal },
         'rl-reset-after-signal lives';
#lives_ok { my $rv = $r.rl-free-line-state }, # XXX Can't run standalone?
#         'rl-free-line-state lives';
#lives_ok { $r.rl-echo-signal( 0 ) },
#         'rl-echo-signal lives';
lives_ok { my $rv = $r.rl-set-paren-blink-timeout( 1 ) },
         'rl-set-paren-blink-timeout lives';
#lives_ok { my $rv = $r.rl-complete-internal( 1 ) },
#         'rl-complete-internal lives';
#lives_ok { my $rv = $r.rl-username-completion-function( 'jgoff', 1 ) },
#         'rl-username-completion-function lives';
#lives_ok { my $rv = $r.rl-filename-completion-function( 'ile.txt', 1 ) },
#         'rl-filename-completion-function lives';
#lives_ok { my $rv = $r.rl-completion-mode( \&callback ) },
#         'rl-completion-mode lives';
#lives_ok { my $rv = $r.rl-save-state( $readline-state ) },
#         'rl-save-state lives';
lives_ok { my $rv = $r.tilde-expand( '~jgoff' ) },
         'tilde-expand lives';
lives_ok { my $rv = $r.tilde-expand-word( 'foo' ) },
         'tilde-expand-word lives';
#lives_ok { my $offset;
#           my $rv = $r.tilde-find-word( 'foo', 1, \$offset ) },
#         'tilde-find-word lives';
#lives_ok { my $rv = $r.rl-restore-state( $readline-state ) },
#         'rl-restore-state lives';
