#!/usr/bin/perl

use warnings;
use strict;

package Logger;

my $instance = undef;

sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	my $time = Utils->new()->getTime("time");
	
	my $self = 
	{
		_logFilePath => $Utils::scriptPath . "/log/output_$time.log",
		_windLogFilePath => $Utils::scriptPath . "/log/WindRiverLocations_$time.log",
		_logDescriptor => undef,
		_windLogDescriptor => undef,
	};
	
	$instance = bless( $self , $class );
	
	return $instance;
}

sub log
{
	my $self = shift;
	my $lognum = shift;
	my $line = shift;

	if( $lognum == 1 )
	{
		if( !defined( $self->{ _logDescriptor } ) )
		{
			open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
		}

		if( defined( $self->{ _logDescriptor } ) )
		{
			my $tf = $self->{ _logDescriptor };
			print $tf $line;			
		}
	}
	
	if( $lognum == 2 )
	{
		if( !defined( $self->{ _windLogDescriptor } ) )
		{
			open( $self->{ _windLogDescriptor }, ">", $self->{ _windLogFilePath } );
		}

		if( defined( $self->{ _windLogDescriptor } ) )
		{
			my $tf = $self->{ _windLogDescriptor };
			print $tf $line;			
		}
	}

	if( $lognum == 3 )
	{
		print $line . "\n";
	}
}

sub tidy()
{
	
        my @arr = FileManager->new()->readFile( Logger->new->{ _windLogFilePath } );
       
        my @skipArray;
        my $lineDiff=0;
        my $lineNum=0;
        my $i=0;
        my $outputStr = "";

        foreach my $line ( @arr )
		{
                if($line =~ m/\@windriver.com|of an applicable Wind River license agreement./i) 
				{
					push(@skipArray, $lineNum-1);
					push(@skipArray, $lineNum);
					$lineDiff+=2;
					
				}
               	$lineNum++;
		}
        
        my $arrSize = @arr;
        
        for ( $i=0 ; $i<$arrSize ; $i++ )
		{
			if( $i ~~ @skipArray )
			{
				next;
			}
			else
			{
				$outputStr .= "$arr[$i]\n";
			}
		}

      	my $writeLocation = Logger->new->{ _windLogFilePath } =~ s/\.log$/_tidied\.log/r; 
      	
      	Logger->new()->log( 3 , "\n$lineDiff lines removed\n");
		
        FileManager->new()->writeFile( $writeLocation , $outputStr );
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
