#!/usr/bin/perl

use warnings;
use strict;

package CLicenseStrategy;
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
			
	if ( $file->{ _fileContentsString } =~ m/\/\*.*?copyright.*?wind river.*?\*\//is ) 
	{
		my $license = $self->prepareLicense( $file->{ _filePath });
		
		$file->{ _fileContentsString } =~ s/(\/\*.*?copyright.*?wind river.*?\*\/)/$license/is;			
		Logger->new()->log( 1 , "REPLACED HEADER: " . $file->{ _filePath } . "\n" );
		
		return 1;
	}			
	return 0;
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



sub prepareLicense
{
	my $self = shift;
	my $filename = shift;

	my $licensePath = LicenseStrategy::getLicense($filename);
	
	Logger->new()->log( 3 , "use license: $licensePath" );
	
	my @licenseText = FileManager->new()->readFile( $licensePath );
	
	my $start_year = $self->{ _StartYear };
	my $curr_year = $self->{ _CurrYear };
	
	my $retVal = "/*";

	foreach my $line( @licenseText ) 
	{
		$line =~ s/STARTDATE/\Q$start_year/g;
		$line =~ s/ENDDATE/\Q$curr_year/g;
	
		$retVal .= " " . $line;
		$retVal .= "\n *";
	}

	$retVal .= "/\n";

	return $retVal;
}

















1;
