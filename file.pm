#!/usr/bin/perl

use warnings;
use strict;

package File;
use LicenseStrategy;

sub new()
{
	my $class = shift;
	my $filename = shift;

	my @fileContentsArray = ();	
	my $fileContentsString = "";	
		
	my $self = 
	{
		_filePath => $filename,
		_fileContentsArray => \@fileContentsArray,
		_fileContentsString => \$fileContentsString
	};
	
	bless( $self , $class );

	return $self;
}

sub open
{
	my $self = shift;
	Logger->new()->log( 3 , "\nopened: " . $self->{ _filePath } );
	@{ $self->{ _fileContentsArray } } = FileManager->new()->readFile( $self->{ _filePath } );
	
	$self->{ _fileContentsString } = Utils->new()->arrayToString( \@{ $self->{ _fileContentsArray } } );
}

sub close
{
	my $self = shift;

	FileManager->new()->writeFile( $self->{ _filePath } , $self->{ _fileContentsString } );
	@{ $self->{ _fileContentsArray } } = undef;
	$self->{ _fileContentsString } = undef;
	Logger->new()->log( 3 , "closed: " . $self->{ _filePath } );
}

sub scan
{
	my $self = shift;
	
	$self->open();

	Logger->new()->log( 3 , "scanning: " . $self->{ _filePath } );

	my $strategy = LicenseStrategy::getStategyInstance($self);
	
	my $headerReplaced = 0;	
	my $defineReplaced;
	my $lineNum = 0;
	
	foreach my $line ( @{ $self->{ _fileContentsArray } } ) 
	{		
		if( $line =~ m/Wind\s?River/ig ) 
		{	
			if ( $headerReplaced != 1 && $line =~ m/(?<!define).*?copyright.*?/i )
			{
				$headerReplaced = $strategy->replaceHeader($self); #returns 1 if regex substitution occurs
				if ($headerReplaced == 1) #prevent windriver log for occurrence if it has been acted upon
				{
					next;
				}
			}
			
			if( $line =~ m/(?<=define).*?copyright.*?/i)
			{
				$defineReplaced = $strategy->replaceDefine($self);	
				if ($defineReplaced == 1) #prevent windriver logging for occurence if it has been acted upon
				{
					next;
				}		
			}
	
			Logger->new()->log( 2 , "Line:" . $lineNum . "," . $self->{ _filePath } . "\n" );
			Logger->new()->log( 2 , "\t$line\n" );
		}

		$lineNum++;
	}
			
	if ( $headerReplaced != 1 ) 
	{		
		$strategy->addHeader($self);
	}
	
	$self->close();
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
