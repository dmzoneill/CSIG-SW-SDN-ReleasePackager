#!/usr/bin/perl

use warnings;
use strict;

package LicenseStrategy;
use CLicenseStrategy;
use PythonLicenseStrategy;
use MakefileLicenseStrategy;
use XMLLicenseStrategy;
use CopyingLicenseStrategy;

sub new()
{
	my $class = shift;
	my $file = shift;
	
	my $curr_year = Utils->new()->getTime("year");
	
	my $self = 
	{
		_StartYear => 2011,
		_CurrYear => $curr_year
	};
	
	bless( $self , $class );
	
	return $self;
}

sub getStategyInstance
{
	my $file = shift;

	my $ext = "";
	
	if( $file->{ _filePath }  =~ m/(\.[^.]+)$/ ) 
	{
		$ext = $1;
	}
	
	my $strategy;
		
	if( $ext eq ".cpp" || $ext eq ".c" || $ext eq ".h" || $ext eq ".onsi" || $ext eq ".i" )
	{
		$strategy = new CLicenseStrategy();
	}
	elsif( $ext eq ".py" || $ext eq ".mk" )
	{
		$strategy = new PythonLicenseStrategy();
	}		
	elsif( $ext eq ".am" || $ext eq ".ac")
	{	
		$strategy = new MakefileLicenseStrategy();
	}
	elsif( $ext eq ".xml" )
	{	
		$strategy = new XMLLicenseStrategy();
	}
	elsif( $file->{ _filePath } =~ m/\/COPYING$/i )
	{
		$strategy = new CopyingLicenseStrategy();
	}
	else
	{
		$strategy = new LicenseStrategy();
	}
	
	return $strategy;
}

sub getLicense
{
	my $filename = shift;

	my $license = "source_code_license";
	my $keyHolder = undef;
	
	foreach my $key ( keys %{ ${ BillOfMaterials->new()->{ _licensingListing } } })
	{
		if ($filename =~ m/($key)/i)
		{
			if(defined $keyHolder)
			{
				if (length($1) > length($keyHolder))
				{
					$keyHolder = $1;
					$license = ${ BillOfMaterials->new()->{ _licensingListing } }->{ $key }
				}
			}
			else
			{
				$keyHolder = $1;
				$license = ${ BillOfMaterials->new()->{ _licensingListing } }->{ $key };
			}
		}
	}
	
	my $licensePath = $Utils::scriptPath . "/licenses/" . $license;
	return $licensePath;
}


sub replaceHeader
{
	return 0;
}

sub addHeader
{
	return 0;
}

sub replaceDefine
{
	return 0;
}


sub prepareLicense
{
	my $self = shift;
	my $filename = shift;

	my $licensePath = LicenseStrategy::getLicense($filename);
	
	my @licenseText = FileManager->new()->readFile( $licensePath );
	
	my $start_year = $self->{ _StartYear };
	my $curr_year = $self->{ _CurrYear };
	
	my $retVal = "";

	foreach my $line( @licenseText ) 
	{
		$line =~ s/STARTDATE/\Q$start_year/g;
		$line =~ s/ENDDATE/\Q$curr_year/g;
	
		$retVal .= $line;
		$retVal .= "\n";
	}

	return $retVal;
}


1;