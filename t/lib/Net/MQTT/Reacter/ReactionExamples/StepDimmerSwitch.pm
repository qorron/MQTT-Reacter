#!/usr/bin/env perl

package Net::MQTT::Reacter::ReactionExamples::StepDimmerSwitch;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose;

use Net::MQTT::Reacter::Reaction;

use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::ExtractAction', 'Net::MQTT::Reacter::Roles::Counter',
;



has '+subscribe_topic',
    default => sub { ['example/step_dimmer_switch'] },
    ;

has '+single_action_mapping', default => sub {
	return {
		full => 'full',
		on   => 'on',
		off  => 'off',
		more => 'increase',
		less => 'decrease',
	};
	},
	;

has '+single_counter_mapping', default => sub {
	return [
		[    # counter: 0
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 0 } ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['OFF', 'OFF'] ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
		],
		[    # counter: 1
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['OFF', 'OFF'] ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
		],
		[    # counter: 2
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['ON', 'OFF'] ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
		],
		[    # counter: 3
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['ON', 'ON'] ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'off' ),
		],
		[    # counter: 4
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp1/power', data    => { power => 1 } ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp2/power', data    => ['ON', 'ON'] ),
			Net::MQTT::Reacter::Reaction->new( topic => 'room/lamp3/power', message => 'on' ),
		]
	];
	},
;

43;

