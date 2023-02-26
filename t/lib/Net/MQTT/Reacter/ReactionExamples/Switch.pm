#!/usr/bin/env perl

package Net::MQTT::Reacter::ReactionExamples::Switch;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose;

use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::ReactionRole', 'Net::MQTT::Reacter::Roles::SwitchRole';


has '+topic',
    default => sub { ['example/switch/#'] },
    ;

has '+state_mapping', default => sub {
    return {
        on  => 'ON',
        off => 'OFF'
    };
    },
    ;

has '+topic_mapping', default => sub {
    return {
        'example/switch/sw1' => ['example/light/l1'],
        'example/switch/sw2' => [ 'example/light/l2', 'example/light/l3' ],
    };
    },
    ;



sub extract_message {
    my ($self, $message) = @_;
    my $json_data = $self->j->decode($message);
    return $json_data->{action};
}

__PACKAGE__->meta()->make_immutable();

42;

