#!/usr/bin/perl

use warnings;
use strict;

package PythonLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub headerPattern
{
	return '#*[^\n]*Copyright.*Wind River[^\n]*';
}

sub logLicenseSelection
{
	return 1;
}

sub licenseStyle
{
	return ( "", "## ", "\n", "" );
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

1;
