unit module Testo;
use Testo::Tester;

our $Tester is export = Testo::Tester.new;

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
