use v6;


#-------------------------------------------------------------------------------
class X::GTK::V3 is Exception {
  our $x-debug = False; # Type Bool is set by GObject;

  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
sub test-catch-exception ( Exception $e, Str $native-sub ) is export {

note "Error type: ", $e.WHAT if $X::GTK::V3::x-debug;
note "Error message: ", $e.message if $X::GTK::V3::x-debug;
note "\nThrown Exception:\n", $e if $X::GTK::V3::x-debug;

  given $e {

#TODO X::Method::NotFound
#     No such method 'message' for invocant of type 'Any'
#TODO Argument
#     Calling gtk_button_get_label(N-GObject, Str) will never work with declared signature (N-GObject $widget --> Str)
#TODO Return
#     Type check failed for return value

    # X::AdHoc
    when .message ~~ m:s/Native call expected return type/ {
      note "Wrong return type of native sub '$native-sub\(...\)'";
      die X::GTK::V3.new(
        :message("Wrong return type of native sub '$native-sub\(...\)'")
      );
      #exit(1);
    }

    # X::AdHoc, X::TypeCheck::Argument or some messages
    when X::TypeCheck::Argument ||
         .message ~~ m:s/will never work with declared signature/ ||
         .message ~~ m:s/Type check failed in binding/ {
      note .message;
      die X::GTK::V3.new(:message(.message));
      #exit(1);
    }

    default {
      note "Could not find native sub '$native-sub\(...\)'";
      die X::GTK::V3.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
      #exit(1);
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

    note "\n[0] $found-routine.gist()\( ", $gobject, ', ', |c.perl, ');'
      if $X::GTK::V3::x-debug;
    $found-routine( $gobject, |c)
  }

  else {
    note "\n[1] $found-routine.gist()\( ", |c.perl, ');'
      if $X::GTK::V3::x-debug;
    $found-routine(|c)
  }
}
