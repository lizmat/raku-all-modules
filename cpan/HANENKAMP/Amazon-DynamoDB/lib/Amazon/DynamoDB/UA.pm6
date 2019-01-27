use v6;

# EXPERIMENTAL API! I am not documenting this officially yet, but I want the
# ability to let a custom UA be used instead. It must implement this interface
# to work.
role Amazon::DynamoDB::UA {
    method request(:$method, :$uri, :%headers, :$content --> Hash) { ... }
}

# Lazy load the default UA
class Amazon::DynamoDB::UA::AutoUA does Amazon::DynamoDB::UA {
    has $!ua;

    method request(:$method, :$uri, :%headers, :$content --> Hash) {
        without $!ua {
            require Amazon::DynamoDB::UA::HTTP::UserAgent;
            $!ua = Amazon::DynamoDB::UA::HTTP::UserAgent.new;
        }

        $!ua.request(:$method, :$uri, :%headers, :$content);
    }
}
