#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::Counter;

use 5.024;
use strict;
use warnings;
use Data::Dumper;


use Log::Any qw($log);
use Moose::Role;

use namespace::autoclean;


has 'resend_on_no_change',
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
	;

has 'single_action_mapping',
	is  => 'ro',
	isa => 'HashRef[Str]',
	;

has 'action_mapping',
	is       => 'ro',
	isa      => 'HashRef[HashRef]',
	required => 1,
	traits   => ['Hash'],
	handles  => {
	can_map_action     => 'exists',
	get_action_mapping => 'get',
	},
	lazy          => 1,
	builder       => '_build_action_mapping',
	documentation => '',
	;

has 'single_counter_mapping',
	is       => 'ro',
	isa => 'ArrayRef[ArrayRef]',
	;

has 'counter_mapping',
	is       => 'ro',
	isa      => 'HashRef[ArrayRef]',
	required => 1,
	traits   => ['Hash'],
	handles  => {
	can_map_counter     => 'exists',
	get_counter_mapping => 'get',
	},
	lazy          => 1,
	builder       => '_build_counter_mapping',
	documentation => 'This stores ordered lists of lists of Net::MQTT::Reacter::Reaction objects for each counter. '
	. 'A counter value points to an elemtent of its list. '
	. 'Once a counter is updates the proper list of Net::MQTT::Reacter::Reaction objects is returned',
	;

has 'counters',
	is       => 'rw',
	isa      => 'HashRef[Int]',
	required => 1,
	traits   => ['Hash'],
	handles  => {
	has_counter  => 'exists',
	get_counter  => 'get',
	_set_counter => 'set',
	},
	documentation => '',
	lazy          => 1,
	builder       => '_build_counters',
	;

has '_default_counter',
	is            => 'ro',
	isa           => 'Str',
	default       => 'default',
	documentation => 'In most cases only one counter is used so no need to name it.',
	;

sub _build_counters {
	my $self = shift;
	return { $self->_default_counter => 0 };
}

sub _build_counter_mapping {
	my $self = shift;
	return { $self->_default_counter => $self->single_counter_mapping };
}

sub _build_action_mapping {
	my $self = shift;
	return { $self->_default_counter => $self->single_action_mapping };
}

sub increase {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		my $index = $self->get_counter($counter);
		$index++;
		my $reactions;
		if ( $reactions = $self->_get_reactions_by_index( $counter, $index ) ) {
			$self->_set_counter( $counter, $index );
			return $reactions;
		}
		elsif ( $self->resend_on_no_change ) {
			return $self->get_reactions($counter);
		}
		else {
			return [];
		}
	}
	else {
		# unknown counter
	}
	return;
}

sub decrease {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		my $index = $self->get_counter($counter);
		if ( $index <= 0 ) {
			if ( !$self->resend_on_no_change ) {
				return [];
			}
		}
		else {
			$index--;
			$self->_set_counter( $counter, $index );
		}
		return $self->get_reactions($counter);
	}
	else {
		# unknown counter
	}
	return;
}
sub full {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		my $mapping;
		if ( $self->can_map_counter($counter)
			&& ( $mapping = $self->get_counter_mapping($counter) ) )
		{
			my $index = $mapping->$#*;
			 $self->_set_counter( $counter, $index );
			return $self->_get_reactions_by_index( $counter, $index );
		}
		else {
			# no counter mapping
		}
	}
	else {
		# unknown counter
	}
	return;
}
sub off {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		if ( $self->can_map_counter($counter)
			)
		{
			return $self->_get_reactions_by_index( $counter, 0 );
		}
		else {
			# no counter mapping
		}
	}
	else {
		# unknown counter
	}
	return;
}
sub on {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		if ( $self->can_map_counter($counter)
			)
		{
			return $self->get_reactions( $counter );
		}
		else {
			# no counter mapping
		}
	}
	else {
		# unknown counter
	}
	return;
}

sub _get_reactions_by_index {
	my ( $self, $counter, $index ) = @_;
		my $mapping;
		if ( $self->can_map_counter($counter)
			&& ( $mapping = $self->get_counter_mapping($counter) ) )
		{
			return $mapping->[$index];
		}
		else {
			# no counter mapping
		}
	return;
}
sub get_reactions {
	my ( $self, $counter ) = @_;
	$counter //= $self->_default_counter;
	if ( $self->has_counter($counter) ) {
		my $index = $self->get_counter($counter);
		return $self->_get_reactions_by_index($counter, $index);
	}
	else {
		# unknown counter
	}
	return;
}

sub react {
	my ($self, $topic, $message) = @_;
    my ($extracted_action, $extracted_counter ) = $self->extract_message($message);
	$extracted_counter //= $self->_default_counter;
	my $mapped_action = $self->get_action_mapping($extracted_counter)->{$extracted_action};
	return $self->$mapped_action($extracted_counter) if $self->can($mapped_action);
	warn "can't $extracted_action";
	return;
}

# sub map_counter {
#     my ( $self, $topic ) = @_;
#     my $extracted_message = $self->extract_message($message);
#     if ($extracted_message) {
#         if ( $self->can_map_state($extracted_message) ) {
#             my $return_message = $self->map_state($extracted_message);
#             if ( $self->can_map_topic($topic) ) {
#                 my @return_pairs = map { [ $_ => $return_message ] }
#                     $self->map_topic($topic)->@*;
#                 return \@return_pairs;
#             }
#             else {
#                 $log->errorf( 'cannot map topic %s', $topic );
#             }
#         }
#         else {
#             $log->errorf( 'cannot map state %s', $extracted_message );
#         }
#     }
#     else {
#         $log->errorf( 'cannot extract state from %s', $message );
#     }
#     return;
# }

# sub extract_message {
#     my ($self, $message) = @_;
#     return $message;
# }






42;

