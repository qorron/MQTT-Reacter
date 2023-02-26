#!/usr/bin/env perl

package Net::MQTT::Reacter::ReactionExamples::Simple;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose;

use namespace::autoclean;

with 'Net::MQTT::Reacter::Roles::ReactionRole';


has '+topic',
    default => sub { ['example/simple/#'] },
    ;

sub payload {
    my ( $self, $topic, $message ) = @_;
    return [[ 'example/reaction', uc $message ]];
}


__PACKAGE__->meta()->make_immutable();

42;

