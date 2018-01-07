use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Reward;

# POST   /V1/reward/mine/use-reward
our sub reward-mine-use-reward(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "reward/mine/use-reward",
        content => to-json $data;
}

