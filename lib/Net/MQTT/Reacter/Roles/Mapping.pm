#!/usr/bin/env perl

package Net::MQTT::Reacter::Roles::Mapping;

use 5.024;
use strict;
use warnings;
use Data::Dumper;


use Log::Any qw($log);
use Moose::Role;

use Net::MQTT::Reacter::Reaction;

use namespace::autoclean;


has 'state_mapping',
    isa      => 'HashRef',
    required => 1,
    traits   => ['Hash'],
    handles  => {
    map_state     => 'get',
    can_map_state => 'exists',
    },
    ;

has 'topic_mapping',
    isa      => 'HashRef[ArrayRef]',
    required => 1,
    traits   => ['Hash'],
    handles  => {
    map_topic     => 'get',
    can_map_topic => 'exists',
    },
    ;


sub react {
	my ( $self, $topic, $message ) = @_;
    my $extracted_message = $self->extract_message($message);
    if ($extracted_message) {
        if ( $self->can_map_state($extracted_message) ) {
            my $return_message = $self->map_state($extracted_message);
            if ( $self->can_map_topic($topic) ) {
				my @return_pairs = map { Net::MQTT::Reacter::Reaction->new( topic => $_, data => $return_message ) }
					$self->map_topic($topic)->@*;
				$log->infof('res: %s', scalar(@return_pairs));
                return \@return_pairs;
            }
            else {
                $log->errorf( 'cannot map topic %s', $topic );
            }
        }
        else {
            $log->errorf( 'cannot map state %s', $extracted_message );
        }
    }
    else {
        $log->errorf( 'cannot extract state from %s', $message );
    }
    return;
}

# sub extract_message {
#     my ($self, $message) = @_;
#     return $message;
# }





42;

