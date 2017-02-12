role HTTP::Server {
  method handler(Callable $sub)    {*} #to be called when request is complete
  method middleware(Callable $sub) {*} #to be called when headers are complete
  method after(Callable $sub)      {*} #to be called when response is complete
  method listen()                  {*}
}
