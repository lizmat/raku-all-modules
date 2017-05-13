unit module Testo;
use Testo::Tester;

our $Tester = Testo::Tester.new;
sub plan   (|c) is export { $Tester.plan:   |c }
sub is     (|c) is export { $Tester.is:     |c }
sub is-eqv (|c) is export { $Tester.is-eqv: |c }
sub is-run (|c) is export { $Tester.is-run: |c }
