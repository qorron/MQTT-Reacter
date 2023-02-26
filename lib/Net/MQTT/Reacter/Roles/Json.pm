#!/usr/bin/perl

package Net::MQTT::Reacter::Roles::Json;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Moose::Role;

use Log::Any qw($log);
use JSON;
use namespace::autoclean;

has 'j',
	is      => 'ro',
	isa     => 'JSON',
	lazy    => 1,
	builder => '_build_j',
	;

sub _build_j {
	my $self = shift;
	my $j;
	if ( $ENV{HARNESS_ACTIVE} || 1 ) {
		$j = JSON->new->pretty->canonical;
	}
	else {
		$j = JSON->new;
	}
	return $j;
}




42;

