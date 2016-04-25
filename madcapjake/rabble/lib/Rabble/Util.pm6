unit module Rabble::Util;

#| u219e - Makes code a little denser
sub infix:<↞>(Array $stack, $item) is export is looser(&infix:<X>){
  $stack.push: $item;
}

#| Internal workings for Quotations and Definitions
sub compile-words(@entries) is export {
  my Callable @actions;
  for @entries -> %entry {
    %entry<immediate>
      ?? %entry<block>()
      !! @actions.push: %entry<block>;
  }
  return anon sub { $_() for @actions }
}
