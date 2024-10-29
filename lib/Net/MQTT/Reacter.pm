#!/usr/bin/env perl

package Net::MQTT::Reacter;

use 5.024;
use strict;
use warnings;
use DDP;

use Moose;

use Log::Any qw($log);
use namespace::autoclean -except => [ 'search_path', 'reaction_objects'];

use Module::Pluggable
    sub_name    => 'reaction_objects',
    search_path => 'Net::MQTT::Reacter::Reaction',
    inner       => 0,
    instantiate => 'new',
;

#use lib qw'../lib lib t/lib';

has 'reactions',
    is      => 'rw',
    isa     => 'ArrayRef[Object]',
    traits  => ['Array'],
    handles => { add_reaction => 'push', },
    lazy    => 1,
    builder => '_build_reactions',
    ;

has 'reaction_namespace',
    is      => 'rw',
    isa     => 'Str',
    default => 'Net::MQTT::Reacter::Reaction',
    ;


sub _build_reactions {
    my $self = shift;
    $self->search_path( new => $self->reaction_namespace );
    my @r = $self->reaction_objects;
    return [@r];
}

__PACKAGE__->meta()->make_immutable();

42;

