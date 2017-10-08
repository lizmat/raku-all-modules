use Operator::feq;
use Text::Levenshtein::Damerau;

class Operator::feq::Levenshtein does Operator::feq {
  method compare($a,$b) {
    return ld($a,$b); 
  }
};

