#!/usr/bin/env perl

package Net::MQTT::Reacter::Reaction;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any ($log);
use JSON;
use Moose;

use namespace::autoclean;

has 'j',
    is       => 'rw',
    isa      => 'JDON',
    builder => '_build_j',
    ;

has 'topic',
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { ['example/topic/#'] },
    ;

sub payload {
    my ( $self, $topic, $message ) = @_;
    $log->errorf( 'Abstract Class used, for %s with %s', $topic, $message );
    return;
}

__PACKAGE__->meta()->make_immutable()









42;

