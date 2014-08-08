#!/usr/bin/perl

use warnings;
use strict;
use file;

package FileManager;

my $instance = undef;

sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	my @fileList = ();
	
	my $self = 
	{
		_fileListing => \@fileList,
		_debug => 1
	};
	
	$instance = bless( $self , $class );
	
	return $instance;
}

sub readFile
{
	my $self = shift;
	my $fname = shift;
	my @retVal = ();
	my $file;	

	if( open( $file , $fname ) )
	{	
		while( my $line = <$file> ) 
		{		
			chomp $line;
			push( @retVal, $line );		
		}

		close( $file );		

		return @retVal;	
	}
	else
	{
		Logger->new()->log( 3 , "Unable to read file: $fname" );	

		return "-1";
	}
}

sub writeFile
{
	my $self = shift;
	my $fname = shift;
	my $inputVal = shift;
	my $file;
	
	if( open( $file , ">" ,$fname ) )
	{	
		print $file $inputVal;	
		close( $file );

		return 0;	
	}
	else
	{
		Logger->new()->log( 3 , "Unable to write to file" );

		return -1;
	}
}

sub getDirectory
{
	my $self = shift;
	my $path = shift;
	
	if( opendir( my $dir , $path ) ) 
	{
		while( my $file = readdir( $dir ) ) 
		{		
			my $file_path = "$path/$file";		
					
			if( $file_path =~ m/\.$/ || $file_path =~ m/\.\.$/ ) #if parent or current folder, skip
			{
				Logger->new()->log( 3 , "Ignored: $file_path" );
				next;
			}					
			if( ( !$self->isIgnoredPath( $file_path ) || $self->isExceptionPath( $file_path ) ) && -f $file_path ) #if not marked as ignored and is a file
			{
				Logger->new()->log( 3 , "+++ allowed: $file_path" );
				push( @{ $self->{ _fileListing } } , new File( $file_path ) );
			}
			elsif( -d $file_path ) #if directory, always run again in case of exceptions on child folders/files
			{
				$self->getDirectory( $file_path );	
			}
			else
			{
				Logger->new()->log( 3 , "Ignored: $file_path " );
			}					
		}
		closedir( $dir );	
	}
	else 
	{
		Logger->new()->log( 3 , "Failed to open dir for $path" );
	}
}


sub printFilesList
{
	my $self = shift;

	foreach my $file ( @{ $self->{ _fileListing } } )
	{
		Logger->new()->log( 3 , $file->get( "_filePath" ) );
	}
}

sub changeFiles
{
	my $self = shift;
	
	foreach my $file ( @{ $self->{ _fileListing } } )
	{
		$file->scan();
	}
}


sub isIgnoredPath
{
	my ( $self, $file_path ) = @_;   

	foreach my $item ( @{ BillOfMaterials->new()->get( "_ignoreListing"  ) } )
	{
		if( $file_path =~ m/$Utils::sourcePath\/$item/ )
		{
			return 1;		
		}
	}

	return 0;
}

sub isExceptionPath
{
	my ( $self, $file_path ) = @_;     

	foreach my $item ( @{ BillOfMaterials->new()->get( "_exceptionListing"  ) } )
	{
		if( $file_path =~ m/$Utils::sourcePath\/$item/ )
		{
			return 1;		
		}
	}

	return 0;
}

sub setMember
{
	my $self = shift;
	my $key = shift;
	my $value = shift;

	$self->{ $key } = $value;
}

sub getMember
{
	my $self = shift;
	my $key = shift;

	return $self->{ $key };
}

1;
