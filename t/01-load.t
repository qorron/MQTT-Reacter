#!/usr/bin/env perl
use 5.024;
use strict;
use warnings;
use Data::Dumper;

use Test::More tests => 2;

use lib qw'lib t/lib';

BEGIN {
    use_ok('Net::MQTT::Reacter');
 #   use_ok('Net::MQTT::Reacter::Reaction');
    use_ok('Net::MQTT::Reacter::ReactionExamples::Simple');
}


