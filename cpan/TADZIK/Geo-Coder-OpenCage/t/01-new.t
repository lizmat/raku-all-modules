use v6;
use Test;
use Geo::Coder::OpenCage;

plan 3;

lives-ok {
    my $cl = Geo::Coder::OpenCage.new: api-key => 'deadbeefcafe';
    pass 'created geocoder object with dummy api key';
}, 'new() lived with api key';

dies-ok { Geo::Coder::OpenCage.new; },
        'exception thrown when no api key passed to new()';
