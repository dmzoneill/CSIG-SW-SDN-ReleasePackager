#!/usr/bin/perl

use warnings;
use strict;

package MakefileLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub headerPattern
{
	return '\#.[^\n]*copyright.[^\n]*wind river.*wind river.[^\n]*\.\s*\#';
}

sub logLicenseSelection
{
	return 1;
}

sub licenseStyle
{
	return ( "#\n#", " ", "\n# ", "\n" );
}

1;
