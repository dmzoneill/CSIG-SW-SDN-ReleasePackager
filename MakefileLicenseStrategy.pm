#!/usr/bin/perl

use warnings;
use strict;

package MakefileLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub new()
{
	my ( $class ) = @_;
	
	my $self = $class->SUPER::new();
	
	bless( $self , $class );
	
	return $self;
}

sub replaceHeader
{
	my $self = shift;
	my $file = shift;

	Logger->new()->log( 3 , "replace header: " . $file->{ _filePath } );
			
	if ( $file->{ _fileContentsString } =~ m/\#.[^\n]*copyright.[^\n]*wind river.*wind river.[^\n]*\.\s*\#/is ) 
	{
		my $license = $self->prepareLicense( $file->{ _filePath });
		
		$file->{ _fileContentsString } =~ s/(\#.[^\n]*copyright.[^\n]*wind river.*wind river.[^\n]*\.\s*\#)/$license/is;			
		Logger->new()->log( 1 , "REPLACED HEADER: " . $file->{ _filePath } . "\n" );
		
		return 1;
	}			
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
	
	Logger->new()->log( 3 , "use license: $licensePath" );
	
	my @licenseText = FileManager->new()->readFile( $licensePath );
	
	my $start_year = $self->{ _StartYear };
	my $curr_year = $self->{ _CurrYear };
	
	my $retVal = "#\n#";

	foreach my $line( @licenseText ) 
	{
		$line =~ s/STARTDATE/\Q$start_year/g;
		$line =~ s/ENDDATE/\Q$curr_year/g;
	
		$retVal .= " " . $line;
		$retVal .= "\n# ";
	}

	$retVal .= "\n";

	return $retVal;
}


1;
