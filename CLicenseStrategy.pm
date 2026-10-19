#!/usr/bin/perl

use warnings;
use strict;

package CLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub headerPattern
{
	return '\/\*.*?copyright.*?wind river.*?\*\/';
}

sub logLicenseSelection
{
	return 1;
}

sub licenseStyle
{
	return ( "/*", " ", "\n *", "/\n" );
}

sub addHeader
{
	my $self = shift;
	my $file = shift;
	
	my $license = $self->prepareLicense( $file->{ _filePath } );
	
	if( $file->{ _fileContentsString } =~ m/\Q$license/s )
	{
		return 0;
	}
	
	Logger->new()->log( 3 , "add header: " . $file->{ _filePath } );
	
	$file->{ _fileContentsString } = $license . $file->{ _fileContentsString };
			
	Logger->new()->log( 1 , "ADDED HEADER: " . $file->{ _filePath } . "\n" );	
	
	return 1;
}

sub replaceDefine
{
	my $self = shift;
	my $file = shift;

	Logger->new()->log( 3 , "replace define: " . $file->{ _filePath } );
	
	if ( $file->{ _fileContentsString } =~ m/(?<=define).*?\".*?Wind River.*?\"/i )
	{	
		my $copyrightDefine = "Copyright (c) $self->{ _StartYear }-$self->{ _CurrYear }, Intel Corporation";
		
		if( $file->{ _fileContentsString } =~ s/\".*?Copyright.*?Wind River.*?\"/"$copyrightDefine"/ig )
		{
			Logger->new()->log( 1 , "REPLACED DEFINE: " . $file->{ _filePath } . "\n" );
		
			return 1;
		}	
	}
	return 0;
}

1;
