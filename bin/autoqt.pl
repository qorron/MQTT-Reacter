#!/usr/bin/env perl
use 5.024;
use strict;
use warnings;
use Data::Dumper;

#use Net::Pushover;
use Net::MQTT::Simple;
use Log::Any::Adapter ('Stderr');

use lib qw( lib lib_private_examples /usr/local/lib/home_automation/perl );
use config;
use Net::MQTT::Reacter;
use Net::MQTT::Reacter::Reaction;


my $config = config->new();

my $mqtt = Net::MQTT::Simple->new( $config->{host}{mqtt} );

my $r = Net::MQTT::Reacter->new(reaction_namespace => 'Net::MQTT::Reacter::MyReactions');
say join "\n", "Loading Plugins:", map {ref} $r->reactions->@*;
my %reactions ;
for my $reactor ($r->reactions->@*) {
	for my $topic ( $reactor->subscribe_topic->@* ) {
		$reactions{$topic} = sub {
			say join ' => ', @_;
			my $reactions = $reactor->react(@_);
			if ( $reactions && ref $reactions eq 'ARRAY' && $reactions->@* ) {
				for my $reaction ( $reactions->@* ) {
					if ( $reaction->retain ) {
						$mqtt->retain( $reaction->topic, $reaction->message );
					}
					else {
						$mqtt->publish( $reaction->topic, $reaction->message );
					}
				}
			}
		}
	}
}

die "no reactors" unless keys %reactions;
say join "\n", "Subscribing to:", sort keys %reactions;

$mqtt->subscribe(%reactions);
$mqtt->run();


