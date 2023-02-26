#!/usr/bin/env perl
use 5.024;
use strict;
use warnings;
use Data::Dumper;


use Test::More tests => 10;

use lib qw'lib t/lib';

use Net::MQTT::Reacter;
use Net::MQTT::Reacter::Reaction;

my $r = Net::MQTT::Reacter->new(reaction_namespace => 'Net::MQTT::Reacter::ReactionExamples');
my @reactions = sort map {ref} $r->reactions->@*;
is_deeply(
	\@reactions,
	[   'Net::MQTT::Reacter::ReactionExamples::Simple',
		'Net::MQTT::Reacter::ReactionExamples::StepDimmerSwitch',
		'Net::MQTT::Reacter::ReactionExamples::Switch'
	],
	'Expected Plugins loaded'
);
is_deeply(
	$r->reactions->[0]->react( 'example/simple/hi', 'hello' ),
	[Net::MQTT::Reacter::Reaction->new( topic => 'example/reaction', message => 'HELLO' )],
	'Example Simple Reaction'
);
is_deeply(
	$r->reactions->[2]->react_in_a_safe_way( 'example/switch/sw1', '{"action":"on"}' ),
	[Net::MQTT::Reacter::Reaction->new( topic => 'example/light/l1', data => 'ON' )],
	'Example Switch Reaction single'
);
is_deeply(
	$r->reactions->[2]->react( 'example/switch/sw2', '{"action":"off"}' ),
	[   Net::MQTT::Reacter::Reaction->new( topic => 'example/light/l2', data => 'OFF' ),
		Net::MQTT::Reacter::Reaction->new( topic => 'example/light/l3', data => 'OFF' )
	],
	'Example Switch Reaction multi'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"off"}' ),
	[   Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 0 } ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['OFF', 'OFF'] ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
	],
	'Example Step Dimmer Switch Reaction off'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"less"}' ),
	[  	],
	'Example Step Dimmer Switch Reaction below zero'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"more"}' ),
	[   Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['OFF', 'OFF'] ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
	],
	'Example Step Dimmer Switch Reaction level 1'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"full"}' ),
	[   Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['ON', 'ON'] ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'on' ),
	],
	'Example Step Dimmer Switch Reaction full'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"more"}' ),
	[ 	],
	'Example Step Dimmer Switch Reaction beyond max'
);
is_deeply(
	$r->reactions->[1]->react( 'example/step_dimmer_switch', '{"action":"less"}' ),
	[   Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['ON', 'ON'] ),
		Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
	],
	'Example Step Dimmer Switch Reaction less'
);
