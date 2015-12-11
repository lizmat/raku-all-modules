module Acme::WTF {
  
  my @dic = <WTF?! OMG!! ZOMG?!>;
  sub die (*@msg) is export is hidden-from-backtrace {
    &CORE::die(@dic.pick~" ", @msg);
  }
  
  sub say (*@msg) is export {
    &CORE::say(@dic.pick~" ", @msg);
  }
}
