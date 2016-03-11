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

	$v1->initPlayer( "bot1","A" ) ;
	$v1->initPlayer(  "bot2","B" ) ;
	$v1->initPlayer(  "bot3","C" ) ;
	$v1->initPlayer(  "human1","D" ) ;
	$v1->initPlayer(  "human2","E" ) ;
#$v1->myfunc() ;
#$v1->initBoard();
#print "\nfirst".$v1->getName();
#print "\n2nd".$v1->setName("tester");
#print "\nrd".$v1->getName();


$v1->startGame();
	$v1->initPlayer(  "human3","F" ) ;


print Dumper($v1);
while( $v1->inGame() ) {

	print $v1->draw();
	print "\n Thrown: ";
	print $v1->getAttrib("throw");
	print "\n Player: ";
	print $v1->getAttrib("turn");




	print "\nMove?";
	my $line=<STDIN>;
	chomp($line);
#print $v1->suggestMove();

#print Dumper($v1);

}





