use v6;


use Pod::Coverage::Result;
    
    
role Pod::Tester {
    has Pod::Coverage::Result @.results = ();
    #| true if any pod is missing
    method are-missing {        
        for @!results -> $result {
            return True unless $result.is_ok;
        }
        return False;
    }

    #| do all needed
    method check {!!!}

    #| override if want custom results
    method get-results {@!results}
}
