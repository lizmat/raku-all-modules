class Net::HTTP::Interfaces { }

role Request {
    method method     { ... }
    method path       { ... }
    method proto      { ... }

    method header     { ... }
    method body       { ... }
    method trailer    { ... }

    method url { ... }
}

role Response {
    method status-code  { ... }
    method header       { ... }
    method body         { ... }
}

role URL {
    method scheme { ... }
    method host   { ... }
    method port   { ... }
    method path   { ... }
    method query  { ... }
}

role Dialer {
    method dial(Request $req) { ... }
}

role RoundTripper does Dialer {
    method round-trip(Request $req --> Response) { ... }
}
