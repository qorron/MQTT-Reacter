#!/usr/bin/perl

package Net::MQTT::Reacter::Reaction;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Moose;

use Log::Any qw($log);
use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::Json';

has 'retain',
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
	;
has 'qos',
	is      => 'rw',
	isa     => 'Int',
	default => 0,
	;
has 'topic',
	is       => 'rw',
	isa      => 'Str',
	required => 1,
	;

has 'message',
	is      => 'rw',
	isa     => 'Str',
	lazy    => 1,
	builder => '_build_message',
	;
has 'data',
	is  => 'rw',
	isa => 'Any',
	;

sub _build_message {
	my $self = shift;
	if ( ref $self->data =~ /^(?:ARRAY|HASH)$/ ) {
		return $self->j->encode( $self->data );
	}
	else {
		return $self->data;
	}
}
42;

