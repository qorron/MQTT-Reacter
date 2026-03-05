#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::ExtractAction;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose::Role;

use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::Json';

sub extract_message {
    my ($self, $message) = @_;
    my $json_data = $self->j->decode($message);
    return $json_data->{action};
}

1;
