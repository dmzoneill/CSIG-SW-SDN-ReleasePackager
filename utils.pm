#!/usr/bin/perl

use warnings;
use strict;

package Utils;

our $scriptPath = "/ons/CSIG-SW-SDN-ReleasePackager";
#our $scriptPath = "/home/jbeegan/CSIG-SW-SDN-ReleasePackager";
our $sourcePath = "/ons/ons-core";
#our $sourcePath = "/home/jbeegan/ons-core";
#our $sourcePath = "/home/jbeegan/Test";

my $instance = undef;


sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	
	my $self = {};
	
	$instance = bless( $self , $class );
	
	return $instance;
}

sub getTime
{
	my $self = shift;
	my $request = shift;
	
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	
	$year += 1900;
	my $retVal;

	if ( $request eq "year" )
	{
		$retVal = $year;
	}
	elsif ( $request eq "time" )
	{
		$retVal = sprintf("%02d:%02d_%02d-%02d-%04d", $hour, $min, $mday, $mon, $year);
	}
	return $retVal;
}

sub arrayToString
{
	my $self = shift;
	my $array = shift;
	my $fileString = ""; 
			
	foreach my $line( @$array ) 
	{
		$fileString .= $line . "\n";
	}	
		
	return $fileString;
}

sub prepareLicense
{
	my $self = shift;
	my $filename = shift;
	my $ext = shift;

	my $licensePath = $Utils::scriptPath . "/source_code_license";

	if( open( my $bom, "licensing" ) )
	{
		while( my $line = <$bom> )
		{
			chomp $line;
			my @arr = split( "," , $line );
		
			if( $filename =~ m/$arr[0]/ )
			{
				$licensePath = $arr[1];
				last;
			}
		}

		close( $bom );
	}
	
	my @licenseText = FileManager->new()->readFile( $licensePath );

	my $retVal = "";
	my $start_year = 2011;
	my $curr_year = $self->getYear();
	
	if( $ext eq ".cpp" || $ext eq ".c" || $ext eq ".h" || $ext eq ".onsi" )
	{
		$retVal = "/*";

		foreach my $line( @licenseText ) 
		{
			$line =~ s/STARTDATE/\Q$start_year/g;
			$line =~ s/ENDDATE/\Q$curr_year/g;
		
			$retVal .= " " . $line;
			$retVal .= "\n *";
		}

		$retVal .= "/\n";
	}
	elsif( $ext eq ".py" )
	{
		$retVal = "\"\"\"\n";

		foreach my $line( @licenseText ) 
		{
			$line =~ s/STARTDATE/\Q$start_year/g;
			$line =~ s/ENDDATE/\Q$curr_year/g;
		
			$retVal .= $line . "\n";
		}

		$retVal .= "\"\"\"\n\n";
	}
	
	return $retVal;
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
