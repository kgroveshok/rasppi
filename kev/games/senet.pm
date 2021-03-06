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
	my $numcounters=shift;
my $boardtype=shift;

    print "in constructor";

    my $key=shift; # db key

    my $self = bless { key=>$key }, $class ;


    setAttrib($self,"boardtype",$boardtype);
    setAttrib($self,"gamestarted",0);

    $self->{SENET_SQUARE_START}="X";

    $self->{SENET_SQUARE_PROTECTED}="P";
    $self->{SENET_SQUARE_LUCKY}="L";
    $self->{SENET_SQUARE_UNLUCKY}="U";
	initBoard($self);

    if( $numcounters eq 0 ) {
    setAttrib($self,"numcounters",getAttrib($self, "defcounters"));
    }    else {
    setAttrib($self,"numcounters",$numcounters);
       }

    return $self;
}

sub inGame {
	my $this=shift;
	# returns true if game is currently in progress

	return getAttrib( $this, "gamestarted" ) == 1;
}


# suggest a move to make (ideal for bots and helpful for humans)
# returns the selec


sub suggestMove {
	my $this=shift;


	# get current player
	my $curPlayer = getAttrib($this, "turn" ) ;

	# get the current throw
	my $curThrow = getAttrib( $this, "throw" ) ;

	# get board data
	my $curAll = getAttrib( $this, "boardall" ) ;


}



sub setAttrib {
    my $self=shift;
    my $attr=shift;
    my $value=shift;

    $self->{$attr}=$value;

    return $value;
}

sub getAttrib {
    my $self=shift;
    my $attr=shift;

    return $self->{$attr};

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

#sub dbConnect {
#    my $dbh;
#    if( $ENABLE_SQL) {
#        $dbh= DBI->connect("dbi:mysql:dbname=aa;host=localhost",
#                "user",
#                "pass",
#                { RaiseError => 0}, ) or die $DBI::errstr;
#
#    }
#    return $dbh;
#}

#sub getDBVal { 
## using a passed key, get the value at a specific node
#    my $key = shift;
#    my $item = shift;
#
#
#    my $dbh=dbConnect();
#    my $sth = $dbh->prepare("SELECT value FROM session_store where key_id='$key' and item='$item'");
#    $sth->execute();
#    my $row;
#    $row = $sth->fetchrow_hashref();
#    $sth->finish();
#    return $row->{value};
#}

#sub setDBVal { 
## using a passed key, set the value at a specific node
#    my $key = shift;
#    my $item = shift;
#    my $value=shift;
#
#
#    my $dbh=dbConnect() ;
#    my $sth=$dbh->prepare("insert into session_store ( key_id, item, value) values ('$key','$item','$value') on duplicate key update value='$value'") ;
#    $sth->execute;
#
#    return $value ;
#}



sub getPlayerAt {
	# returns player who is at square

	my $this=shift;
	my $pos= shift ;


	
	foreach my $player ( split( / /, getAttrib($this,"players")))  {
			print STDERR "\nboard for player $player";

		my $thisBoard = getAttrib( $this, $player.".pos") ;
#		my $thisSign = getAttrib( $this, $player.".symbol") ;

		if( substr($thisBoard, $pos, 1 ) ne "_" ) {
			return $player;
		}
#
}

	return "";
}



sub getCounterAt {
	# returns the counter name at square

	my $this=shift;
	my $pos= shift ;


	
	foreach my $player ( split( / /, getAttrib($this,"players")))  {
			print STDERR "\nboard for player $player";

		my $thisBoard = getAttrib( $this, $player.".pos") ;
#		my $thisSign = getAttrib( $this, $player.".symbol") ;

		if( substr($thisBoard, $pos, 1 ) ne "_" ) {
			return $player;
		}
#
}

	return "";
}




#	rotation


sub move {
	my $this=shift;
	my $counter=shift;

	print STDERR "\nMove counter $counter";

	my $thisThrow= getAttrib( $this, "throw");

	if( $thisThrow == 4 or $thisThrow == 6 ) {
		print STDERR "\nCan bring a counter out";
	}

	my $thisTurn=getAttrib( $this, "turn") ;


	moveTo( $this, $counter, $thisThrow ) ;
#	if( $thisTurn eq "b" ) {
#		print STDERR "\nMove bot counter";
#		setAttrib( $this, "turn","h" ) ; # set bot 
#	} else {
#
#		print STDERR "\nMove human counter";
#		setAttrib( $this, "turn","b" ) ; # set bot 
#	}

# create a module to handle placement
# give it the params
# 1. full board layout
# 2. player that is moving
# 3. player that is not moving
# 4. the rolled number
# 5. the counter to move
#

# see if the counter is waiting to come out

	if( index( $this, $counter) > 0 ) {
		if( $thisThrow == 4 or $thisThrow == 6 ) {

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
}

sub moveTo {
	my $this=shift;
	my $counter=shift;
	my $moveby=shift;

	# if there is a counter at point...

	

	# is counter own player?
	# yes then prevent move
	#  return 0;
	# if another player
	#  if protected square stop move return 0;
	#  if unlucky square then loose counter
	#  remove players piece back to stack 
	#  continue with update position
	


	# update counter position

	return 1; #ok
}

sub throw {
	my $this=shift;

	my $thisThrow = ThrowSticks();
	setAttrib( $this, "throw",$thisThrow ) ; # set bot 
		print STDERR "\nThrown: $thisThrow";
}


sub initPlayer {
	my $this=shift;
	my $player=shift;
	my $playerSign=shift ; # symbol for the player on the board

	if( getAttrib($this,"gamestarted") eq 0 ) {

		print STDERR "\nNew player joining $player";

		my $thisBoard=getAttrib( $this, "board");
		$thisBoard =~ s/./_/g;

		setAttrib( $this, "$player.pos", $thisBoard );
		setAttrib( $this, "$player.symbol", $playerSign );


		setAttrib( $this, "$player.counter", substr("ABCDEFGHIJKLMNOPQ",0,getAttrib( $this, "numcounters")) );

		setAttrib( $this, "players", $player." ".getAttrib( $this, "players") ) ; 
	}
	else { 
		print STDERR "\nGame already underway, cant add new player $player";
	}
}


sub initBoard {
	my $this=shift;
# init new board
# testing setup board

	my $thisBoard;

	if( getAttrib( $this, "boardtype") == 2 ) {
		$thisBoard=newBoard2($this) ;
	} else  {
		$thisBoard=newBoardStd($this) ;
	}
	my $thisStart=$thisBoard;
	$thisStart =~ s/./_/g;

	setAttrib( $this, "players", "" ) ; 


	setAttrib( $this, "board", $thisBoard ) ;
	setAttrib( $this, "boardall", "" ) ;
#           setAttrib( $this, "posb", $thisStart ) ; # init the player positions on the board
#          setAttrib( $this, "posh", $thisStart ) ; # init the player positions on the board
#         setAttrib( $this, "counterb", "ABCDE" ) ; # init the bot player counters
#        setAttrib( $this, "counterh", "HIJKL" ) ; # init the human player counters
	setAttrib( $this, "turn","" ) ; # set bot 
}


#	initPlayer( $this, "bot1" ) ;
#	initPlayer( $this, "bot2" ) ;
#	initPlayer( $this, "bot3" ) ;
#	initPlayer( $this, "human1" ) ;
#	initPlayer( $this, "human2" ) ;


            # decide on first player

sub startGame {	
	my $this=shift;
	my $thisThrow = 0;
	my $thisTurn=0;
	while( $thisThrow ne 4 and $thisThrow ne 6 ) { 
		print STDERR "\nStart scan";
		foreach $thisTurn ( split( / /, getAttrib( $this, "players" )) )  {

			print STDERR "\n Deciding on first throw for $thisTurn";


			$thisThrow = throwSticks($this);



			if( $thisThrow == 4 or $thisThrow == 6 ) { 
				setAttrib( $this, "turn",$thisTurn ) ; # set bot 
					setAttrib( $this, "throw",$thisThrow ) ; # set bot 
					last;
			}
		}		
	}

	setAttrib($this,"gamestarted",1);
}



sub draw {
	my $this=shift;
#        print STDERR "new board layout: $thisBoard";
# init new board
# testing setup board

	my $thisBoard=getAttrib( $this, "board") ;
	print STDERR "\ndraw current board. $thisBoard" ;
	my $thisTurn=getAttrib( $this, "turn") ;
	print STDERR "\ncurrent player turn is: $thisTurn" ;
	my $thisThrow=getAttrib( $this, "throw") ; # set bot 
		print STDERR "\ncurrent roll is: $thisThrow" ;

# produce composite board

	my $full=$thisBoard;

# for all players 

	foreach my $player ( split( / /, getAttrib($this,"players")))  {
			print STDERR "\nboard for player $player";

		my $thisBoard = getAttrib( $this, $player.".pos") ;
		my $thisSign = getAttrib( $this, $player.".symbol") ;

	for( my $c=0; $c <= length($thisBoard); $c++ ) {
		if( substr($thisBoard,$c,1) ne "_" ) {
			#substr($full, $c, 0)=substr($thisBoard,$c, 1);
			substr($full, $c, 0)=$thisSign;
		}
	}
#
}
			print STDERR "\nComp board: $full ";


			setAttrib( $this, "boardall", $full ) ;

}


sub turn {
	my $this=shift;

	my $thisThrow=getAttrib( $this, "throw") ; # set bot 
		print STDERR "\ncurrent roll is: $thisThrow" ;
	my $thisTurn=getAttrib( $this, "turn") ;
	print STDERR "\ncurrent player turn is: $thisTurn" ;
} 




sub newBoardStd {
	my $this=shift;
    my $board ;
    $board = '.' x 30 ;  # standard board size


    substr($board, 4, 1) = $this->{SENET_SQUARE_START};
    substr($board, 6, 1) = $this->{SENET_SQUARE_START};

    substr($board, 15, 1) = $this->{SENET_SQUARE_PROTECTED};
    substr($board, 20, 1) = $this->{SENET_SQUARE_LUCKY};
    substr($board, 25, 1) = $this->{SENET_SQUARE_UNLUCKY};
    
    print STDERR "\nboard layout created: $board";

    setAttrib( $this, "defcounters",5);
    return $board;
}

sub newBoard2 {
	my $this=shift;
    my $board ;
    $board = '.' x 50 ;  # standard board size


    substr($board, 4, 1) = $this->{SENET_SQUARE_START};
    substr($board, 6, 1) = $this->{SENET_SQUARE_START};

    substr($board, 15, 1) = $this->{SENET_SQUARE_PROTECTED};
    substr($board, 32, 1) = $this->{SENET_SQUARE_PROTECTED};
    substr($board, 20, 1) = $this->{SENET_SQUARE_LUCKY};
    substr($board, 30, 1) = $this->{SENET_SQUARE_LUCKY};
    substr($board, 25, 1) = $this->{SENET_SQUARE_UNLUCKY};
    substr($board, 45, 1) = $this->{SENET_SQUARE_UNLUCKY};
    setAttrib( $this, "defcounters",8);
    
    print STDERR "\nboard layout created: $board";
    return $board;
}
#sub DrawBoard {
#    my $board=shift; # pass the board layout to draw
#    my $layout="";
#    
#    $layout=$board;
#
#
#    return $layout;
#}

sub throwSticks {
	my $this=shift;
	my $thrown=0;

	while( !$thrown ) {
		$thrown=int(rand(6));
		print STDERR " Thrown: $thrown";

		if( $thrown == 5 ) { print STDERR " Reroll "; $thrown =0 ; }
	}

            setAttrib( $this, "throw",$thrown ) ; # set bot 
            print STDERR " Final Thrown: $thrown";
	return $thrown;

}




1;
