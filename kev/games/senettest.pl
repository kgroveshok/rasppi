#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: us.pl
#
#        USAGE: ./us.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/29/2016 09:43:25 AM
#     REVISION: ---
#===============================================================================

use senet;
use strict;
use warnings;
use utf8;
use Data::Dumper;

my $v1=senet->new(0,1);

	$v1->initPlayer( "bot1" ) ;
	$v1->initPlayer(  "bot2" ) ;
	$v1->initPlayer(  "bot3" ) ;
	$v1->initPlayer(  "human1" ) ;
	$v1->initPlayer(  "human2" ) ;
#$v1->myfunc() ;
#$v1->initBoard();
#print "\nfirst".$v1->getName();
#print "\n2nd".$v1->setName("tester");
#print "\nrd".$v1->getName();


$v1->startGame();
	$v1->initPlayer(  "human3" ) ;

print Dumper($v1);
