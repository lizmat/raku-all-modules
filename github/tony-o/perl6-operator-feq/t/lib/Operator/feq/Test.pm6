use Operator::feq;

class Operator::feq::Test does Operator::feq {
  method compare($a, $b) {
    $*C();
    return 0;
  }
}
