use v6;

#-------------------------------------------------------------------------------
class X::GTK::V3 is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
sub test-catch-exception ( Exception $e, Str $native-sub ) is export {

#note "Error type: ", $e.WHAT;
#note "Error message: ", $e.message;
#note "Exception: ", $e;

  given $e {

#TODO X::Method::NotFound
#     No such method 'message' for invocant of type 'Any'
#TODO Argument
#     Calling gtk_button_get_label(N-GObject, Str) will never work with declared signature (N-GObject $widget --> Str)
#TODO Return
#     Type check failed for return value

    # X::AdHoc
    #when .message ~~ m:s/Cannot invoke this object/ {
    #  die X::GTK::V3.new(
    #    :message("Could not find native sub '$native-sub\(...\)'")
    #  );
    #}

    # NotFound, triggered by getting signature from an Any
    #when .message ~~ m:s/"No such method 'signature' for invocant of type 'Callable'"/ {
    #  die X::GTK::V3.new(
    #    :message("Could not find native sub '$native-sub\(...\)'")
    #  );
    #}

    # X::AdHoc
    when .message ~~ m:s/Native call expected return type/ {
      die X::GTK::V3.new(
        :message("Wrong return type of native sub '$native-sub\(...\)'")
      );
    }

    # X::AdHoc
    when .message ~~ m:s/will never work with declared signature/ {
      die X::GTK::V3.new(:message(.message));
    }

    when X::TypeCheck::Argument {
      die X::GTK::V3.new(:message(.message));
    }

    default {
      die X::GTK::V3.new(
#        :message(.message)
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }
}

#-------------------------------------------------------------------------------
sub test-call ( Callable:D $found-routine, $gobject, |c --> Mu ) is export {

  my List $sig-params = $found-routine.signature.params;
#note "TC 0 parameters: ", $found-routine.signature.params;
#note "TC 1 type 1st arg: ", $sig-params[0].type.^name;

  if +$sig-params and
     $sig-params[0].type.^name ~~ m/^ ['GTK::V3::G' .*?]? 'N-G' / {
#note "\ncall with widget: ", $gobject.gist, ', ', |c.gist;
    $found-routine( $gobject, |c)
  }

  else {
#note "\ncall without widget: ", |c.gist;
    $found-routine(|c)
  }
}
