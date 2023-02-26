#!/usr/bin/env perl
use 5.024;
use strict;
use warnings;
use Data::Dumper;


use Test::More tests => 4;

use lib qw'lib t/lib';

use Net::MQTT::Reacter;

my $r = Net::MQTT::Reacter->new(reaction_namespace => 'Net::MQTT::Reacter::ReactionExamples');
my @reactions = sort map {ref} $r->reactions->@*;
is_deeply(
    \@reactions,
    [   'Net::MQTT::Reacter::ReactionExamples::Simple',
        'Net::MQTT::Reacter::ReactionExamples::Switch'
    ],
    'Expected Plugins loaded'
);
is_deeply(
    $r->reactions->[0]->react( 'example/simple/hi', 'hello' ),
    [ [ 'example/reaction', 'HELLO' ] ],
    'Example Simple Reaction'
);
is_deeply(
     $r->reactions->[1]->react( 'example/switch/sw1', '{"action":"on"}' ) ,
    [ [ 'example/light/l1', 'ON' ] ],
    'Example Switch Reaction single'
);
is_deeply(
    $r->reactions->[1]->react( 'example/switch/sw2', '{"action":"off"}' ),
    [ [ 'example/light/l2', 'OFF' ], [ 'example/light/l3', 'OFF' ] ],
    'Example Switch Reaction multi'
);
