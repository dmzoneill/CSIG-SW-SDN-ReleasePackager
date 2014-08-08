#!/usr/bin/perl

use warnings;
use strict;

package LogTidy;

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
        
        my $arrSize=@arr;
        
        for ($i=0;$i<$arrSize;$i++)
		{
			if($i ~~ @skipArray)
			{
				next;
			}
			else
			{
				$outputStr .= "$arr[$i]\n";
			}
		}

      	my $writeLocation = Logger->new->{ _windLogFilePath } =~ s/\.log$/_tidied\.log/r; 
		
        FileManager->new()->writeFile( $writeLocation , $outputStr );
}

1;
