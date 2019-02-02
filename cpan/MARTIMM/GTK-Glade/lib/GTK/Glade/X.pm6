use v6;

#-------------------------------------------------------------------------------
class X::Gui is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
class X::Glade is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
sub test-catch-exception ( Exception $e, Str $native-sub ) is export {

note "Error type: ", $_.WHAT;
note "Error message: ", .message;
#.note;
  given $e {

    # X::AdHoc
    when .message ~~ m:s/Cannot invoke this object/ {
      die X::Gui.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }

    # X::AdHoc
    when .message ~~ m:s/Native call expected return type/ {
      die X::Gui.new(
        :message("Wrong return type of native sub '$native-sub\(...\)'")
      );
    }

    # X::AdHoc
    when .message ~~ m:s/will never work with declared signature/ {
      die X::Gui.new(
        :message("Wrong call arguments to native sub '$native-sub\(...\)'")
      );
    }

    when X::TypeCheck::Argument {
      die X::Gui.new(:message(.message));
    }

    default {
      die X::Gui.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }
}
