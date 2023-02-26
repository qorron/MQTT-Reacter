#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::ReactionRole;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use JSON;
use Moose::Role;

use namespace::autoclean;

has 'j',
    is      => 'ro',
    isa     => 'JSON',
#default => sub { JSON->new->canonical->pretty->utf8 },
    lazy    => 1,
    builder => '_build_j',
    ;

has 'topic',
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { ['#'] },
    ;

# has 'payload',
#     is      => 'rw',
#     isa     => 'ArrayRef[ArrayRef]',
#     lazy    => 1,
#     builder => '_build_payload',
#     ;

requires 'payload';

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

sub react {
    my ($self, $topic, $message ) = @_;
    my @return;
    eval {
        @return = $self->payload($topic, $message );
    };  
    if ($@ )  {
        warn "failed topic: $topic\nmsg: >>$message<<\n\n$@";
    }
    return @return;
}   



sub extract_message {
    my ($self, $message) = @_;
    return $message;
}

42;

