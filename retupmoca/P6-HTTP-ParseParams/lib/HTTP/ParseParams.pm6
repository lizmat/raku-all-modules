use URI::Encode;

#| Parses cookies, query parameters, and post data from HTTP requests.
module HTTP::ParseParams;

#| Pass in some data and a type, and get back a hash containing the passed parameters
our sub parse(Str $data, Bool :$cookie, Bool :$urlencoded is copy, Bool :$formdata is copy, Str :$content-type --> Hash) {
    =begin pod
    Pass :cookie for cookie data, :urlencoded for query parameters or x-www-form-urlencoded postdata, or :formdata for multipart/form-data postdata.

    Alternatively, pass :content-type(...) to have the function pick the correct postdata encoding for you. Will die if we don't
    recognize the content type.

    If there are multiple parameters with the same name, the result hash will contain a list of values.
    =end pod
    if $content-type {
        if $content-type eq 'application/x-www-form-urlencoded' {
            $urlencoded = True;
        }
        elsif $content-type eq 'multipart/form-data' {
            $formdata = True;
        }
        else {
            die "Unable to understand content type $content-type";
        }
    }

    if $cookie {
        my @cookies = $data.split(/\;\s/);
        my %cookiedata;
        for @cookies {
            my @parts = .split(/\=/, 2);
            if %cookiedata{@parts[0]} {
                %cookiedata{@parts[0]} = [ %cookiedata{@parts[0]}.flat, @parts[1] ].flat;
            }
            else {
                %cookiedata{@parts[0]} = @parts[1];
            }
        }

        return %cookiedata;
    }
    elsif $formdata {
        =pod Note that multipart/form-data parsing is NYI

        die "NYI";
    }
    elsif $urlencoded {
        my @params = $data.split(/\&|\;/);
        my %paramdata;
        for @params {
            my @parts = .split(/\=/, 2);
            @parts[1] = uri_decode(@parts[1]);
            if %paramdata{@parts[0]} {
                %paramdata{@parts[0]} = [ %paramdata{@parts[0]}.flat, @parts[1] ].flat;
            }
            else {
                %paramdata{@parts[0]} = @parts[1];
            }
        }
        return %paramdata;
    }
    else {
        die "Nothing to do!";
    }
}
