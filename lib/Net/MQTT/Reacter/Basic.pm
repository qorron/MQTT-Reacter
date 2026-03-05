#!/usr/bin/env perl
package Net::MQTT::Reacter::Basic;

use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Log::Any qw($log);
use Moose;

use namespace::autoclean;

# This is the base role for every reacetion
# It provides these features:
# - eval'd execution of your code so errors do not crash the service.


has 'subscribe_topic',
  is       => 'ro',
  isa      => 'ArrayRef[Str]',
  required => 1,
  ;

# has 'payload',
#     is      => 'rw',
#     isa     => 'ArrayRef[ArrayRef]',
#     lazy    => 1,
#     builder => '_build_payload',
#     ;

sub react {
}


sub can_run {
	return 1;
}

sub react_in_a_safe_way {
    my ($self, $topic, $message ) = @_;
    my @return;
    eval {
        @return = $self->react($topic, $message );
    };  
    if ($@ )  {
		$log->errorf( 'failed topic: %s\nmsg: >>%s<<\nError: %s', $topic, $message, $@ );
    }
    return @return;
}   

42;

