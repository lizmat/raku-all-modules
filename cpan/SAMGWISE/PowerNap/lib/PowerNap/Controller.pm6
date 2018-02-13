use v6;
use PowerNap;

role PowerNap::Controller {
  method verb-get(:$request --> PowerNap::Result) {
    result-err 501, 'GET not supported for this endpoint.'
  }

  method verb-post(:$request --> PowerNap::Result) {
    result-err 501, 'POST not supported for this endpoint.'
  }

  method verb-put(:$request --> PowerNap::Result) {
    result-err 501, 'PUT not supported for this endpoint.'
  }

  method verb-patch(:$request --> PowerNap::Result) {
    result-err 501, 'PATCH not supported for this endpoint.'
  }

  method verb-delete(:$request --> PowerNap::Result) {
    result-err 501, 'DELETE not supported for this endpoint.'
  }

  method dispatch-verb(PowerNap::Verb $verb, Map $request --> PowerNap::Result) {
    try {
      CATCH {
        when X::TypeCheck {
          warn $_.perl;
          return result-err(501, "Type error, this endpoint cannot accept the arguments provided. Please refer to your API documentation.")
        }
        when X::AdHoc {
          if .payload.starts-with('Required named parameter') {
            # Hack for handdling missing named parameters in a signiture
            return result-err(501, "Missing property error.\n{ .payload }.")
          }
          else {
            warn $_.perl;
            return result-err(500, "This endpoint encountered an error when trying to service your request.")
          }
        }
        default {
          warn $_.perl;
          return result-err(500, "This endpoint encountered an error when trying to service your request.")
        }
      }

      given $verb {
        when PowerNap::Verb::GET {
            self.verb-get: |$request
        }
        when PowerNap::Verb::POST {
          self.verb-post: |$request
        }
        when PowerNap::Verb::PUT {
          self.verb-put: |$request
        }
        when PowerNap::Verb::PATCH {
          self.verb-patch: |$request
        }
        when PowerNap::Verb::DELETE {
          self.verb-delete: |$request
        }
        default {
          result-err 501, 'Unsupported verb: { $verb.perl }';
        }
      }
    }
  }
}
