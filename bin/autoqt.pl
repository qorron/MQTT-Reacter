#!/usr/bin/env perl
use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Net::MQTT::Simple;
use Log::Any::Adapter ('Stderr');
use Getopt::Long;

# use lib qw( lib lib_private_examples /usr/local/lib/home_automation/perl );

use Net::MQTT::Reacter;
use Net::MQTT::Reacter::Reaction;


my $reaction_namespace = 'Net::MQTT::Reacter::MyReactions';
my $mqtt_host          = '127.0.0.1';
my $verbose;
GetOptions(
    "namespace=s" => \$reaction_namespace,
    "host=s"      => \$mqtt_host,            # string
    "verbose"     => \$verbose
  )                                          # flag
  or die("Error in command line arguments\n");

my $mqtt = Net::MQTT::Simple->new( $mqtt_host );

my $r = Net::MQTT::Reacter->new(reaction_namespace => $reaction_namespace);
say join "\n", "Loading Plugins:", map {ref} $r->reactions->@*;
my %reactions ;
for my $reactor ($r->reactions->@*) {
	for my $topic ( $reactor->subscribe_topic->@* ) {
		$reactions{$topic} = sub {
			say sprintf( 'Reactor for %s is a %s Message: %s', $_[0], ref($reactor), $_[1] );
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


