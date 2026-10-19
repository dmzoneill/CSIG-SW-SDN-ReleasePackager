#!/usr/bin/perl

use warnings;
use strict;

package Logger;
use logtidy;
use hashaccess;
our @ISA = ( "HashAccess" );

my $instance = undef;

sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	my $time = Utils->new()->getTime("time");
	
	my $self = 
	{
		_logFilePath => $Utils::scriptPath . "/log/output_$time.log",
		_windLogFilePath => $Utils::scriptPath . "/log/WindRiverLocations_$time.log",
		_logDescriptor => undef,
		_windLogDescriptor => undef,
	};
	
	$instance = bless( $self , $class );
	
	return $instance;
}

sub log
{
	my $self = shift;
	my $lognum = shift;
	my $line = shift;

	if( $lognum == 1 )
	{
		if( !defined( $self->{ _logDescriptor } ) )
		{
			open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
		}

		if( defined( $self->{ _logDescriptor } ) )
		{
			my $tf = $self->{ _logDescriptor };
			print $tf $line;			
		}
	}
	
	if( $lognum == 2 )
	{
		if( !defined( $self->{ _windLogDescriptor } ) )
		{
			open( $self->{ _windLogDescriptor }, ">", $self->{ _windLogFilePath } );
		}

		if( defined( $self->{ _windLogDescriptor } ) )
		{
			my $tf = $self->{ _windLogDescriptor };
			print $tf $line;			
		}
	}

	if( $lognum == 3 )
	{
		print $line . "\n";
	}
}

sub tidy()
{
	my ( $writeLocation, $outputStr, $lineDiff ) = LogTidy::buildTidiedWindLog();

	Logger->new()->log( 3 , "\n$lineDiff lines removed\n");

	FileManager->new()->writeFile( $writeLocation , $outputStr );
}

1;
