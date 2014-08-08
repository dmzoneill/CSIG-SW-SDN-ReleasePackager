#!/usr/bin/perl

use warnings;
use strict;

package ReleasePackager;

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

sub get
{
    my $self = shift;
    my $key = shift;

    return $self->{ $key };
}

sub set
{
    my $self = shift;
    my $key = shift;
    my $value = shift;

    $self->{ $key } = $value;
}

1;
