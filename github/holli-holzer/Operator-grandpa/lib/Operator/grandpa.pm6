class Operator::grandpa
{
  multi sub infix:«𝄇»(Any \obj, Callable \code) is export
  {
    ($_ = &(code)(obj)).defined ?? ($_ 𝄇 code) !! obj;
  }

  multi sub infix:«:|»(Any \obj, Callable \code) is export
  {
    ($_ = &(code)(obj)).defined ?? ($_ :| code) !! obj;
  }

  multi sub infix:«|:»(Any $obj is copy, Callable \code) is export
  {
    ($_ = &(code)($obj)).defined ?? ($_ :| code) !! $obj;
  }

  multi sub infix:«𝄆»(Any $obj is copy, Callable \code) is export
  {
    ($_ = &(code)($obj)).defined ?? ($_ |: code) !! $obj;
  }
}
