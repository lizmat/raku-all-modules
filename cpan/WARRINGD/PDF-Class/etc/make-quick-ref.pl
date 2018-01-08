use v6;
use PDF::DAO::Array;
use PDF::DAO::Dict;
use PDF::DAO::Stream;
use PDF::DAO::Tie::Array;
use PDF::DAO::Tie::Hash;
use PDF::Content::XObject;

my %classes;

my Set $std-methods .= new: flat( <cb-init cb-finish type subtype <anon> delegate-function>, (PDF::DAO::Stream, PDF::DAO::Array).map: *.^methods>>.name);
my Set $stream-accessors .= new: <Length Filter DecodeParms F FFilter FDecodeParms DL>;

sub scan-classes($path) {
    for $path.dir {
        next if /[^|'/']['.'|t|Type|Loader]/;
        if .d {
            scan-classes($_);
        }
        else {
            next unless /'.pm'$/;
            my @class = .Str.split('/');
            @class.shift;
            @class.tail ~~ s/'.pm'$//;
            my $name = @class.join: "::";
warn $name;
            (require ::($name)).so;
            %classes{$name} = ::($name);
        }
    }
    # delete base clasess
    %classes.keys.map: {
        my @c = .split('::'); @c.pop;
        %classes{@c.join('::')}:delete;
    }
}

scan-classes('lib'.IO);

for %classes.keys.sort({ when 'PDF::Class' {'A'}; when 'PDF::Catalog' {'B'}; default {$_}}) -> $name {
    my $class = %classes{$name};
    my $type = do given $class {
        when PDF::DAO::Array|PDF::DAO::Tie::Array  {'array'}
        when PDF::DAO::Stream|PDF::Content::XObject['Form'] {'stream'}
        when PDF::DAO::Dict|PDF::DAO::Tie::Hash   {'dict'}
        default { next }
    };

    my $doc = $class.WHY // '';
    my @accessors = $class.^attributes.grep({.name !~~ /descriptor/ && (.can('entry') || .can('index')) }).map(*.name.subst(/^.'!'/, '')).grep(* ∉ $stream-accessors).sort.unique;
    my @methods = $class.^methods.map(*.name).grep(* ∉ $std-methods).sort.unique;
    say "$name | $type | {@accessors.join: ', '} | {@methods.join: ', '} | $doc"
        if @accessors || @methods;
}
