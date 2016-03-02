#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: s.pl
#
#        USAGE: ./s.pl  
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
#      CREATED: 02/29/2016 09:42:33 AM
#     REVISION: ---
#===============================================================================

package senet ;

use strict;
use warnings;
use utf8;

#use Exporter qw(import);

#our $VERSION     = 1.00;
#our @ISA         = qw(Exporter);
#our @EXPORT_OK   = qw(myfunc);
#our %EXPORT_TAGS = ( DEFAULT => [qw(myfunc)],
 #                Both    => [qw(myfunc)]);


#y $sussvar1;
#

sub new {
    my $class=shift;

    print "in constructor";

    my $key=shift; # db key

    my $self = bless { key=>$key }, $class ;

    return $self;
}

sub setAttrib {
    my $self=shift;
    my $attr=shift;
    my $value=shift;

    $self->{$attr}=$value;

    return $value;
}

sub getName {
    my $self=shift;
    return $self->{name};
}

sub myfunc {
my $self=shift;
print "hello";
print $self->{var1};
print $self->{var2};
}

# db functions

sub dbConnect {
    my $dbh;
    if( $ENABLE_SQL) {
        $dbh= DBI->connect("dbi:mysql:dbname=aa;host=localhost",
                "user",
                "pass",
                { RaiseError => 0}, ) or die $DBI::errstr;

    }
    return $dbh;
}

sub getDBVal { 
# using a passed key, get the value at a specific node
    my $key = shift;
    my $item = shift;


    my $dbh=dbConnect();
    my $sth = $dbh->prepare("SELECT value FROM session_store where key_id='$key' and item='$item'");
    $sth->execute();
    my $row;
    $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row->{value};
}

sub setDBVal { 
# using a passed key, set the value at a specific node
    my $key = shift;
    my $item = shift;
    my $value=shift;


    my $dbh=dbConnect() ;
    my $sth=$dbh->prepare("insert into session_store ( key_id, item, value) values ('$key','$item','$value') on duplicate key update value='$value'") ;
    $sth->execute;

    return $value ;
}










#	rotation


if( $pack->{key}->{engine} eq "senet" ) {
    print STDERR "playing senet";

    print STDERR Dumper( $pack ) ;


          my $thisBoard=getTrackRoot( $key, "senetboard") ;
          my $thisPositionsB=getTrackRoot( $key, "senetposb") ;
          my $thisPositionsH=getTrackRoot( $key, "senetposh") ;
          my $thisB=getTrackRoot( $key, "senetcounterb") ;
          my $thisH=getTrackRoot( $key, "senetcounterh") ;
         print STDERR "\ndraw current board. $thisBoard" ;
         print STDERR "\ndraw bot player positions. $thisPositionsB" ;
         print STDERR "\ndraw human player positions. $thisPositionsH" ;
         print STDERR "\ndraw bot counters to play. $thisB" ;
         print STDERR "\ndraw human counters to play. $thisH" ;
        my $thisTurn=getTrackRoot( $key, "senetturn") ;
         print STDERR "\ncurrent player turn is: $thisTurn" ;
            my $thisThrow=getTrackRoot( $key, "senetrolled") ; # set bot 
         print STDERR "\ncurrent roll is: $thisThrow" ;

    if( $pack->{key}->{cmd} eq "move" ) {

        my $counter=$pack->{key}->{vars}->{arg1};
        print STDERR "\nMove counter $pack->{key}->{vars}->{arg1}";

        if( $thisThrow = 4 or $thisThrow = 6 ) {
            print STDERR "\nCan bring a counter out";
        }

        my $thisTurn=getTrackRoot( $key, "senetturn") ;
        if( $thisTurn eq "b" ) {
            print STDERR "\nMove bot counter";
            setTrackRoot( $key, "senetturn","h" ) ; # set bot 
        } else {

            print STDERR "\nMove human counter";
            setTrackRoot( $key, "senetturn","b" ) ; # set bot 
        }

# create a module to handle placement
# give it the params
# 1. full board layout
# 2. player that is moving
# 3. player that is not moving
# 4. the rolled number
# 5. the counter to move
#

        # see if the counter is waiting to come out

        if( index( $thisB, $counter) > 0 ) {
            if( $thisThrow = 4 or $thisThrow = 6 ) {
                # bring it out
                # is there a counter already at the position
                # if so put it back to waiting
                # place counter
}           
}
        # scan board for the counter to move
        # found counter
        # can we move that many squares?
        # if there a special square at the destination?
        # is there a counter already there?
        # if protected and sqaure taken then cant move
        # if special square then place and take action
        # is the move going to come off of the board?                
 


} elsif( $pack->{key}->{cmd} eq "throw" ) {

                my $thisThrow = senetThrowSticks();
            setTrackRoot( $key, "senetrolled",$thisThrow ) ; # set bot 
            print STDERR "\nThrown: $thisThrow";
} elsif( $pack->{key}->{cmd} eq "newgame" ) {
        # init new board
        # testing setup board

           my $thisBoard=senetNewBoard() ;
            my $thisStart=$thisBoard;
            $thisStart =~ s/./_/g;

           setTrackRoot( $key, "senetboard", $thisBoard ) ;
           setTrackRoot( $key, "senetboardall", "" ) ;
           setTrackRoot( $key, "senetposb", $thisStart ) ; # init the player positions on the board
           setTrackRoot( $key, "senetposh", $thisStart ) ; # init the player positions on the board
           setTrackRoot( $key, "senetcounterb", "ABCDE" ) ; # init the bot player counters
           setTrackRoot( $key, "senetcounterh", "HIJKL" ) ; # init the human player counters
            setTrackRoot( $key, "senetturn","b" ) ; # set bot 

            # decide on first player

            my $thisThrow = 0;
            my $thisTurn=0;

            print STDERR "\nDeciding on first throw";

            while( !$thisThrow ) {

                $thisThrow = senetThrowSticks();

                

                if( $thisThrow ne 4 and $thisThrow ne 6 ) { 
                    print STDERR "\nReroll";
                    $thisThrow=0;

                    if( $thisTurn ) { 

                    print STDERR "\nBot turn";
            setTrackRoot( $key, "senetturn","b" ) ; # set bot 
$thisTurn=0;
} else {

                    print STDERR "\nHuman turn";
            setTrackRoot( $key, "senetturn","h" ) ; # set bot 
$thisTurn=1;
}
                    }
}

            setTrackRoot( $key, "senetrolled",$thisThrow ) ; # set bot 
                                


#        print STDERR "new board layout: $thisBoard";
    } elsif( $pack->{key}->{cmd} eq "redraw" ) {
        # init new board
        # testing setup board

          my $thisBoard=getTrackRoot( $key, "senetboard") ;
          my $thisPositionsB=getTrackRoot( $key, "senetposb") ;
          my $thisPositionsH=getTrackRoot( $key, "senetposh") ;
          my $thisB=getTrackRoot( $key, "senetcounterb") ;
          my $thisH=getTrackRoot( $key, "senetcounterh") ;
         print STDERR "\ndraw current board. $thisBoard" ;
         print STDERR "\ndraw bot player positions. $thisPositionsB" ;
         print STDERR "\ndraw human player positions. $thisPositionsH" ;
         print STDERR "\ndraw bot counters to play. $thisB" ;
         print STDERR "\ndraw human counters to play. $thisH" ;
        my $thisTurn=getTrackRoot( $key, "senetturn") ;
         print STDERR "\ncurrent player turn is: $thisTurn" ;
            my $thisThrow=getTrackRoot( $key, "senetrolled") ; # set bot 
         print STDERR "\ncurrent roll is: $thisThrow" ;

        # produce composite board
        #
        my $full=$thisBoard;
        for( my $c=0; $c<=length($thisPositionsB); $c++ ) {
            if( substr($thisPositionsB,$c,1) ne "_" ) {
                substr($full, $c, 0)=substr($thisPositionsB,$c, 1);
}
            if( substr($thisPositionsH,$c,1) ne "_" ) {
                substr($full, $c, 0)=substr($thisPositionsH,$c, 1);
}
}

        print STDERR "\nComp board: $full ";
       

           setTrackRoot( $key, "senetboardall", $full ) ;
    

    } elsif( $pack->{key}->{cmd} eq "turn" ) {
        # get current turn
          
            my $thisThrow=getTrackRoot( $key, "senetrolled") ; # set bot 
         print STDERR "\ncurrent roll is: $thisThrow" ;
        my $thisTurn=getTrackRoot( $key, "senetturn") ;
         print STDERR "\ncurrent player turn is: $thisTurn" ;
    }
} else {
# otherwise lets process ritual stuff

my $rngstream = $pack->{key}->{cmd}->{rngstream};		
	
	if( defined( $rngstream) ) {
	setTrackRoot($key,"rngstream",$rngstream);
}
# TODO id if this ritual ref is a new one or to add to a current running one
# TODO store the bot payload
# TODO to roll up the bot payload to engine level contribution
# TODO intrep the payload. is it command to create, produce a result, or intent applied
# senet game code
#




sub senetNewBoard {
    my $board ;
    $board = '.' x 30 ;  # standard board size

    substr($board, 4, 1) = $SENET_SQUARE_START;
    substr($board, 6, 1) = $SENET_SQUARE_START;

    substr($board, 15, 1) = $SENET_SQUARE_PROTECTED;
    substr($board, 20, 1) = $SENET_SQUARE_LUCKY;
    substr($board, 25, 1) = $SENET_SQUARE_UNLUCKY;
    
    print STDERR "\nboard layout created: $board";
    return $board;
}

sub senetDrawBoard {
    my $board=shift; # pass the board layout to draw
    my $layout="";
    
    $layout=$board;


    return $layout;
}

sub senetThrowSticks {
    my $thrown=0;
    
    while( !$thrown ) {
        $thrown=int(rand(6));
        print STDERR "\nThrown $thrown";

        if( $thrown == 5 ) { print STDERR "\nReroll"; $thrown =0 ; }
}
    
return $thrown;

}




1;
