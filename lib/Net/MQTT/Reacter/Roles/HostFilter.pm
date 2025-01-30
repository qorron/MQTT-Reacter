#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::HostFilter;

use 5.024;
use strict;
use warnings;
use DDP;

use Sys::Hostname;
use Log::Any qw($log);
use Moose::Role;

use namespace::autoclean;

has 'allowed_hosts',
  is  => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
  ;

override 'can_run' => sub {
    my $self     = shift;
    my $hostname = hostname;
    return grep { $hostname eq $_ } $self->allowed_hosts->@*;
  };

1;
