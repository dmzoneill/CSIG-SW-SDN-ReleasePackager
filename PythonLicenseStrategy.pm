#!/usr/bin/perl

use warnings;
use strict;

package PythonLicenseStrategy;
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
##.*?Copyright.*Wind River.*?##		
	if ( $file->{ _fileContentsString } =~ m/#*[^\n]*Copyright.*Wind River[^\n]*/is ) 
	{
		my $license = $self->prepareLicense( $file->{ _filePath } );
		
		$file->{ _fileContentsString } =~ s/(#*[^\n]*Copyright.*Wind River[^\n]*)/$license/is;
		Logger->new()->log( 1 , "REPLACED HEADER: " . $file->{ _filePath } . "\n" );
		
		return 1;
	}			



#if ( $file->{ _fileContentsString } =~ m/\"\"\".*?copyright.*?\"\"\"/is ) 
#	{
#		my $license = $self->prepareLicense( $file->{ _filePath } );
#		
#		$file->{ _fileContentsString } =~ s/(\"\"\".*?copyright.*?\"\"\")/$license/is;
#		Logger->new()->log( 1 , "REPLACED HEADER: " . $file->{ _filePath } . "\n" );
#		
#		return 1;
#	}		
	return 0;
}

sub addHeader
{
	my $self = shift;	
	my $file = shift;
	
	Logger->new()->log( 3 , "add header: " . $file->{ _filePath } );
	
	my $license = $self->prepareLicense( $file->{ _filePath } );
	
	if( $file->{ _fileContentsString } =~ m/\Q$license/s )
	{
		return 0;
	}
	
	if( ${$file->{ _fileContentsArray }}[0] =~ m/(^#!.*)/)
	{
		my $search =  ${$file->{ _fileContentsArray }}[0];
		my $replace = ${$file->{ _fileContentsArray }}[0] . "\n\n" . $license;
	
		if ( $file->{ _fileContentsString } =~ s/$search/$replace/s )
		{
			Logger->new()->log( 1 , "ADDED HEADER: " . $file->{ _filePath } . "\n" );
		}
	}
	else
	{
		$file->{ _fileContentsString } = $license . $file->{ _fileContentsString };
		Logger->new()->log( 1 , "ADDED HEADER: " . $file->{ _filePath } . "\n" );
	}		
	
	return 1;
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

	my $retVal = "";
	
	foreach my $line( @licenseText ) 
	{
		$line =~ s/STARTDATE/\Q$start_year/g;
		$line =~ s/ENDDATE/\Q$curr_year/g;
	
		$retVal .= "## " . $line . "\n";
	}
	

#my $retVal = "\"\"\"\n";

#foreach my $line( @licenseText ) 
#{
#	$line =~ s/STARTDATE/\Q$start_year/g;
#	$line =~ s/ENDDATE/\Q$curr_year/g;
#
#	$retVal .= $line . "\n";
#}

#$retVal .= "\"\"\"\n\n";

	
	return $retVal;
}














1;
