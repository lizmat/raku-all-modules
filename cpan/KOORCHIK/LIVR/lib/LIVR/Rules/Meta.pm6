unit module LIVR::Rules::Meta;
use LIVR::Validator;
use LIVR::Utils;

our sub nested_object([Hash $livr-rules], %builders) {
    my $validator = LIVR::Validator.new(livr-rules => $livr-rules)
        .register-rules(%builders)
        .prepare();

    return sub ($nested-object, %all-values, $output is rw) {
        return if is-no-value($nested-object);
        return 'FORMAT_ERROR' unless $nested-object ~~ Hash;

        my $result = $validator.validate( $nested-object );

        if $result.defined {
            $output = $result;
            return;
        } else {
            return $validator.errors;
        }
    }
}

our sub list_of(@args is copy, %builders) {
    my @rules;
    if (@args[0] ~~ Array) {
        @rules = |@args[0];
    } else {
        @rules = @args;
    }

    my $validator = LIVR::Validator.new(livr-rules => { field => @rules })
        .register-rules(%builders)
        .prepare();

    return sub ($values, %all-values, $output is rw) {
        return if is-no-value($values);
        return 'FORMAT_ERROR' unless $values ~~ Array;

        my ( @results, @errors );

        for @$values -> $value {
            my $result = $validator.validate({field => $value});
            

            if $result.defined {
                @results.push( $result<field> );
                @errors.push(Any);
            } else {
                 @errors.push( $validator.errors()<field> );
                 @results.push(Any);
            }
        }

        if @errors.grep(!!*) {
            return @errors;
        } else {
            $output = @results;
            return;
        }
    }
}

our sub list_of_objects([Hash $livr-rules], %builders) {
    my $validator = LIVR::Validator.new(livr-rules => $livr-rules)
        .register-rules(%builders)
        .prepare();

    return sub ($objects, %all-values, $output is rw) {
        return if is-no-value($objects);
        return 'FORMAT_ERROR' unless $objects ~~ Array;

        my ( @results, @errors );

        for @$objects -> $object {
            my $result = $validator.validate($object);
            
            if $result.defined {
                @results.push( $result );
                @errors.push(Any);
            } else {
                 @errors.push( $validator.errors() );
                 @results.push(Any);
            }
        }

        if @errors.grep(!!*) {
            return @errors;
        } else {
            $output = @results;
            return;
        }
    }
}

our sub list_of_different_objects([Str $selector-field, Hash $livrs], %builders) {
    my %validators;
    
    for %$livrs.kv -> $selector-value, $livr-rules {
        my $validator = LIVR::Validator.new(livr-rules => $livr-rules)
            .register-rules(%builders)
            .prepare();

        %validators{$selector-value} = $validator;
    }

    return sub ($objects, %all-values, $output is rw) {
        return if is-no-value($objects);
        return 'FORMAT_ERROR' unless $objects ~~ Array;

        my ( @results, @errors );

        for @$objects -> $object {
            if $object !~~ Hash || !$object{$selector-field} || !%validators{ $object{$selector-field} } {
                @errors.push('FORMAT_ERROR');
                next;
            }

            my $validator = %validators{ $object{$selector-field} };
            my $result = $validator.validate($object);
            
            if $result.defined {
                @results.push( $result );
                @errors.push(Any);
            } else {
                 @errors.push( $validator.errors() );
                 @results.push(Any);
            }
        }

        if @errors.grep(!!*) {
            return @errors;
        } else {
            $output = @results;
            return;
        }
    }
}

our sub variable_object([Str $selector-field, Hash $livrs], %builders) {
    my %validators;
    
    for %$livrs.kv -> $selector-value, $livr-rules {
        my $validator = LIVR::Validator.new(livr-rules => $livr-rules)
            .register-rules(%builders)
            .prepare();

        %validators{$selector-value} = $validator;
    }

    return sub ($object, %all-values, $output is rw) {
        return if is-no-value($object);

        if $object !~~ Hash || !$object{$selector-field} || !%validators{ $object{$selector-field} } {
            return 'FORMAT_ERROR';
        }

        my $validator = %validators{ $object{$selector-field} };
        my $result = $validator.validate( $object );

        if $result.defined {
            $output = $result;
            return;
        } else {
            return $validator.errors;
        }
    }
}

our sub livr_or(@rule-sets, %builders) {
    my @validators = @rule-sets.map( -> $livr-rules {
        LIVR::Validator.new(livr-rules => {field => $livr-rules})
            .register-rules(%builders)
            .prepare();
    });

    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);

        my $last-error;

        for @validators -> $validator {
             my $result = $validator.validate({ field => $value });
             if $result.defined {
                 $output = $result<field>;
                 return;
             } else {
                 $last-error = $validator.errors()<field>
             }
        }

        return $last-error if $last-error;
        return;
    }
}
