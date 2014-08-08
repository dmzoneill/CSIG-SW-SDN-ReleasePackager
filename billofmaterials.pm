#!/usr/bin/perl

use warnings;
use strict;

package BillOfMaterials;

my $instance = undef;

sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	my @ignoreList = ();
	my @exceptionList = ();
	my $licenseHash = {};
	
	my $self = 
	{
		_ignoreFilePath => $Utils::scriptPath . "/ignoreList",
		_exceptionFilePath => $Utils::scriptPath . "/exceptionList",
		_licensingFilePath => $Utils::scriptPath . "/exceptionList",
		_ignoreListing => \@ignoreList,
		_exceptionListing => \@exceptionList,
		_licensingListing => \$licenseHash,
		_debug => 1
	};
	
	$instance = bless( $self , $class );
	
	return $instance;
}

sub readIgnoreList
{
	my $self = shift;

	my @a = ();
	my @ignore = FileManager->new()->readFile( $self->{ _ignoreFilePath } );
	
	foreach my $ign ( @ignore )
	{
		$ign =~ s/^\s+//;
		$ign =~ s/\s+$//;
		
		if( $ign ne "" )
		{
			push( @a , $ign );
		}
	}

	my @b = @{ $self->{ _ignoreListing } };

	@{ $self->{ _ignoreListing } } = ( @a , @b );
}

sub readExceptionList
{
	my $self = shift;

	my @a = ();
	my @exception = FileManager->new()->readFile( $self->{ _exceptionFilePath } );
	
	foreach my $exc ( @exception )
	{
		$exc =~ s/^\s+//;
		$exc =~ s/\s+$//;
		
		if( $exc ne "" )
		{
			push( @a , $exc );
		}
	}

	my @b = @{ $self->{ _exceptionListing } };

	@{ $self->{ _exceptionListing } } = ( @a , @b );
}

sub getLicenseList
{
	my $self = shift;
	my $filename = shift;

	if( open( my $fh, "licensing" ) )
	{
		while( my $line = <$fh> )
		{
			chomp $line;
			my @arr = split( "," , $line );
#print "Arr[0] = $arr[0] \n";
#print "Arr[1] = $arr[1] \n";
			
			${ $self->{ _licensingListing } }->{$arr[0]} = $arr[1];
		}
		close( $fh );
	}
}

sub printIgnoreList
{
	my $self = shift;

	foreach my $file ( @{ $self->{ _ignoreListing } } )
	{
		Logger->new()->log( 3 , $file );
	}
}

sub printExceptionList
{
	my $self = shift;

	foreach my $file ( @{ $self->{ _exceptionListing } } )
	{
		Logger->new()->log( 3 , $file );
	}
}

sub printLicenseList
{
	my $self = shift;
	my $printout;

	foreach my $key ( keys %{ ${ $self->{ _licensingListing } } })
	{
#print $key . "\n";
$printout = $key . "=" . "${ $self->{ _licensingListing } }->{ $key }" . "\n";
Logger->new()->log( 3 , $printout );
	}
}



















sub set
{
	my $self = shift;
	my $key = shift;
	my $value = shift;

	$self->{ $key } = $value;
}

sub get
{
	my $self = shift;
	my $key = shift;

	return $self->{ $key };
}

1;
