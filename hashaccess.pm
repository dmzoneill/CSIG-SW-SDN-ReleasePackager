#!/usr/bin/perl

use warnings;
use strict;

package HashAccess;

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
