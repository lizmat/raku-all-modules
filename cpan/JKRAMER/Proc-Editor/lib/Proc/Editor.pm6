
=begin pod

=head1 NAME

Proc::Editor - Start a text editor

=head1 SYNOPSIS

  use Proc::Editor;

  my $text = edit('original text');
  say "Edited text: {$text.trim}";

=head1 DESCRIPTION

Proc::Editor runs a text editor and returns the edited text.

=head1 ROUTINES

=head2 C<edit(...)>

This is merely a shortcut for convenience, all arguments are passed on to
C<Proc::Editor.new.edit(...)>.

=head1 METHODS

=head2 C<new(:editors(...))>

Create a new instance of C<Proc::Editor>. C<:editors> may be used to override
the default list of editors to try. By default, the environment variables
$VISUAL and $EDITOR are checked, then it tries /usr/bin/vi, /bin/vi and /bin/ed
(in that order).

=head2 C<edit(Str $text?, IO::Path :$file, Bool :$keep)>

Writes C<$text> to a temporary file runs an editor with that file as argument.
On success, the contents of the file are returned. If C<$file> is defined, it
is used instead of creating a temporary file. The file used (temporary or not)
are deleted afterwards unless C<:keep> is provided.

=head2 C<edit-file(IO::Path $path)>

Starts an editor with the given C<$path> as argument. Returns the editors
exit-code on success (which should always be 0) or dies on error.

=head1 AUTHOR

Jonas Kramer <jkramer@mark17.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Jonas Kramer

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

class Proc::Editor:ver<0.0.2> {
  has @.editors = (
    %*ENV<VISUAL>,
    %*ENV<EDITOR>,
    |</usr/bin/vi /bin/vi /bin/ed>
  ).grep(*.defined);

  # TODO: Check if the file already exists and if so, try other paths.
  method temporary-file(--> IO::Path) {
    $*TMPDIR.add(('edit', $*PID, $.WHERE, now.Rat, 10000.rand.Int).join('-'))
  }

  method edit-file(IO::Path:D $path) {
    my $exitcode;

    for @.editors.grep: { .e && .f && .x with .IO } -> $editor {
      my $proc = Proc::Async.new: $editor, $path.absolute;

      react {
        whenever $proc.start {
          $exitcode = .exitcode;
          done;
        }

        # Catch SIGINT and pass it on to the edior, otherwise it'll kill the
        # parent process (us).
        whenever signal(SIGINT) {
          $proc.kill('INT');
        }
      }

      CATCH {
        default {
          # Silently discard exceptions, since we're trying several editors
          # that may not exist so "not found" errors are to be expected.
        }
      }

      return $exitcode if $exitcode.defined;
    }

    die "No working editor found";
  }

  multi method edit(Proc::Editor:D: Str $text?, IO::Path :$file, Bool :$keep) {
    my $temporary-file = $file // $.temporary-file;

    LEAVE {
      $temporary-file.unlink unless $keep;
    }

    $temporary-file.spurt($text) if $text.defined;

    my $exitcode = $.edit-file($temporary-file);

    if $exitcode == 0 {
      return $temporary-file.slurp;
    }
    else {
      fail "Failed to invoke editor";
    }
  }

  multi method edit(Proc::Editor:U: Str $text?) {
    return Proc::Editor.new.edit($text, |%_);
  }
}

sub edit(|args) is export(:edit) {
  Proc::Editor.edit(|args);
}
