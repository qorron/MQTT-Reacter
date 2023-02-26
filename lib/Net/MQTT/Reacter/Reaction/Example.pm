#!/usr/bin/env perl

package Net::MQTT::Reacter::Reaction::Example;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any ($log);
use JSON;
use Moose;

use namespace::autoclean;

extends 'Net::MQTT::Reacter::Reaction';


has '+topic',
    default => sub { ['example/topic/#'] },
    ;

override 'payload' => sub {
    my ( $self, $topic, $message ) = @_;
    $log->errorf( 'Abstract Class used, for %s with %s', $topic, $message );
    return;
};


__PACKAGE__->meta()->make_immutable()

42;

