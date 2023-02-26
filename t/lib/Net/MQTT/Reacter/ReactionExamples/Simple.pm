#!/usr/bin/env perl

package Net::MQTT::Reacter::ReactionExamples::Simple;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose;

use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::Basic';


has '+subscribe_topic',
    default => sub { ['example/simple/#'] },
    ;

sub react {
	my ( $self, $topic, $message ) = @_;
	return [Net::MQTT::Reacter::Reaction->new( topic => 'example/reaction', message => uc $message )];
}


__PACKAGE__->meta()->make_immutable();

42;

