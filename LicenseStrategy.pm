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
		$strategy = CLicenseStrategy->new();
	}
	elsif( $ext eq ".py" || $ext eq ".mk" )
	{
		$strategy = PythonLicenseStrategy->new();
	}		
	elsif( $ext eq ".am" || $ext eq ".ac")
	{	
		$strategy = MakefileLicenseStrategy->new();
	}
	elsif( $ext eq ".xml" )
	{	
		$strategy = XMLLicenseStrategy->new();
	}
	elsif( $file->{ _filePath } =~ m/\/COPYING$/i )
	{
		$strategy = CopyingLicenseStrategy->new();
	}
	else
	{
		$strategy = LicenseStrategy->new();
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
	my $self = shift;
	my $file = shift;

	my $pattern = $self->headerPattern();

	if( !defined $pattern )
	{
		return 0;
	}

	Logger->new()->log( 3 , $self->headerSearchLog() . $file->{ _filePath } );

	if ( $file->{ _fileContentsString } =~ m/$pattern/is )
	{
		my $license = $self->prepareLicense( $file->{ _filePath } );

		$file->{ _fileContentsString } =~ s/($pattern)/$license/is;
		Logger->new()->log( 1 , $self->headerReplacedLog() . $file->{ _filePath } . "\n" );

		return 1;
	}

	return 0;
}

sub headerPattern
{
	return;
}

sub headerSearchLog
{
	return "replace header: ";
}

sub headerReplacedLog
{
	return "REPLACED HEADER: ";
}

sub addHeader
{
	return 0;
}

sub replaceDefine
{
	return 0;
}

sub logLicenseSelection
{
	return 0;
}

sub licenseStyle
{
	return ( "", "", "\n", "" );
}

sub renderStyledLicense
{
	my ( $lines, $start_year, $curr_year, $prefix, $line_prefix, $line_suffix, $suffix ) = @_;

	my $retVal = $prefix;

	foreach my $line ( @{$lines} )
	{
		$line =~ s/STARTDATE/\Q$start_year/g;
		$line =~ s/ENDDATE/\Q$curr_year/g;

		$retVal .= $line_prefix . $line . $line_suffix;
	}

	$retVal .= $suffix;

	return $retVal;
}

sub prepareLicense
{
	my $self = shift;
	my $filename = shift;

	my $licensePath = LicenseStrategy::getLicense($filename);

	if( $self->logLicenseSelection() )
	{
		Logger->new()->log( 3 , "use license: $licensePath" );
	}

	my @licenseText = FileManager->new()->readFile( $licensePath );

	my $start_year = $self->{ _StartYear };
	my $curr_year = $self->{ _CurrYear };

	my ( $prefix, $line_prefix, $line_suffix, $suffix ) = $self->licenseStyle();

	return LicenseStrategy::renderStyledLicense(
		\@licenseText,
		$start_year,
		$curr_year,
		$prefix,
		$line_prefix,
		$line_suffix,
		$suffix
	);
}


1;
