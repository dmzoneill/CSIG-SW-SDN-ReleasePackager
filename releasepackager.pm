#!/usr/bin/perl

use warnings;
use strict;

package ReleasePackager;
use hashaccess;
our @ISA = ( "HashAccess" );

sub new()
{
	my $class = shift;
	
	my $self = 
	{
	    one => shift,
        two => shift,
        three => shift
	};
	
	bless( $self , $class );
	
	return $self;
}

1;
