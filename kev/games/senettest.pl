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

use suss;
use strict;
use warnings;
use utf8;
use Data::Dumper;

my $v1=suss->new(3,5);

$v1->myfunc() ;

print "\nfirst".$v1->getName();
print "\n2nd".$v1->setName("tester");
print "\nrd".$v1->getName();


print Dumper($v1);
