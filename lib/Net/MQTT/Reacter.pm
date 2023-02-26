#!/usr/bin/env perl

package Net::MQTT::Reacter;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Moose;

use namespace::autoclean;

has 'reaction',
    is       => 'rw',
    isa      => 'ArrayRef[Net::MQTT::Reacter::Reaction]',
    traits   => ['Array'],
    handlers => { add_reaction => 'push', },
    ;


__PACKAGE__->meta()->make_immutable()

42;

