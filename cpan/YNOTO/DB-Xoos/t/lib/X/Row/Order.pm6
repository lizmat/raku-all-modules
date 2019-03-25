use DB::Xoos::Row;
unit class X::Row::Order does DB::Xoos::Row;

#convenience methods
method reopen-duplicate {
  my $new-order = self.duplicate;
  $new-order.status('open');
  $new-order.update;
  $new-order;
}
