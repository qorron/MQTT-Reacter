#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::SwitchRole;

use 5.024;
use strict;
use warnings;
use Data::Dumper;


use Log::Any qw($log);
use Moose::Role;

use namespace::autoclean;


sub payload {
    my ( $self, $topic, $message ) = @_;
    return;
}

sub extract_message {
    my ($self, $message) = @_;
    return $message;
}



42;

