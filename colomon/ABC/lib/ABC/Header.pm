use v6;

class ABC::Header {
    has @.lines; # array of Pairs representing each line of the ABC header
    
    method add-line($name, $data) {
        self.lines.push($name => $data);
    }

    method set-key($new-key) {
        my $found = False;
        for self.lines <-> $line {
            if $line.key eq "K" {
                $line.value = $new-key;
                $found = True;
            }
        }
        self.lines.push("K" => $new-key) unless $found;
    }
    
    method get($name) {
        self.lines.grep({ .key eq $name });
    }

    method get-first-value($name) {
        my $pair = self.lines.first({ .key eq $name });
        $pair ?? $pair.value !! Any;
    }
    
    method is-valid() {
        self.lines.elems > 1 
        && self.lines[0].key eq "X"
        && self.get("T").elems > 0
        && self.get("M").elems == 1
        && self.get("L").elems == 1
        && self.get("X").elems == 1
        && self.get("K").elems == 1
        && self.lines[*-1].key eq "K";
    }
}