package Net::MQTT::Reacter::Roles::MultiMapping;

use 5.024;
use strict;
use warnings;
use DDP;

use Log::Any qw($log);
use Moose::Role;

use Net::MQTT::Reacter::Reaction;

use namespace::autoclean;


has 'multi_mapping',
    isa      => 'HashRef[HashRef]',
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
	$log->infof( 'Got %s -> %s message: %s', $topic, $message, $extracted_message, );
    if ($extracted_message) {
        if ( $self->can_map_topic($topic) ) {
            my $topic_tree = $self->map_topic($topic);
            if ( exists $topic_tree->{$extracted_message}
                && ref $topic_tree->{$extracted_message} eq 'ARRAY' )
            {
                my @return_pairs = map {
                    Net::MQTT::Reacter::Reaction->new(
                        topic => $_->[0],
                        data  => $_->[1]
                    )
                } $topic_tree->{$extracted_message}->@*;
				$log->infof('Mapping %s to %s messages',$extracted_message, scalar(@return_pairs));
                return \@return_pairs;
            }
            else {
                $log->errorf( 'cannot map state %s', $extracted_message );
            }
        }
        else {
            $log->errorf( 'cannot map topic from %s', $topic );
        }
    }
    else {
        $log->errorf( 'cannot extract action from %s', $message );
    }
    return;
}

1;

