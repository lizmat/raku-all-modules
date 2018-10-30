use v6;
use lib 'lib';
use Test;
use Slang::Mosdef;

plan 2;

# 5 factorial
is λ ( &f ) {
  λ ( \n ) {
    return f(&f)(n);
  }
}(
  λ ( &g ) {
    λ ( \n ) {
        return n==1 ?? 1 !! n * g(&g)(n-1);
    }
})(5), 120, '5 factorial with λ';

# also 5 factorial
is lambda ( &f ) {
  lambda ( \n ) {
    return f(&f)(n);
  }
}(
  lambda ( &g ) {
    lambda ( \n ) {
        return n==1 ?? 1 !! n * g(&g)(n-1);
    }
})(5), 120, '5 factorial with lambda';


