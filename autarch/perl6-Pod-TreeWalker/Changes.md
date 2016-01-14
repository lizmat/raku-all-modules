## v0.0.2 - 2015-12-26

* Make Pod::TreeWalker.walk-pod work with a Seq as well as an Array. While
  internally Perl 6 won't generate a Seq, if you generate Pod objects by hand
  you might end up passing one to walk-pod, and it might as well work.


## v0.0.2 - 2015-12-25

* Fixed some edge cases with handling of lists. In some cases lists were not
  ended properly. This doesn't happen with normal Pod because of the way list
  items are always contained in paragraph blocks. However, if you created your
  own Pod objects from scratch then the list would not be ended.


## v0.0.1 - 2015-12-24

* First release upon an unsuspecting world
