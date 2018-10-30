unit module Testo;
use Testo::Tester;

our $Tester is export = Testo::Tester.new;
my Bool:D $seen-done = False;
END { $seen-done or done-testing }

sub group  (|c) is export {
    my $outer-t = ($*Tester//$Tester);
    {
        my $*Tester = Testo::Tester.new: group-level => 1+$outer-t.group-level;
        $outer-t.group: $*Tester, |c
    }
}
sub plan   (|c) is export { ($*Tester//$Tester).plan:   |c }
sub is     (|c) is export { ($*Tester//$Tester).is:     |c }
sub is-eqv (|c) is export { ($*Tester//$Tester).is-eqv: |c }
sub is-run (|c) is export { ($*Tester//$Tester).is-run: |c }

sub done-testing (:$no-exit) is export {
    $seen-done = True;
    ($*Tester//$Tester).done-testing unless $no-exit;
}
