#!/usr/bin/perl

use warnings;
use strict;

package XMLLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub headerPattern
{
	return '<!--.*copyright.*wind river.[^\n]*\.\s?-->';
}

sub logLicenseSelection
{
	return 1;
}

sub licenseStyle
{
	return ( "<!--\n", "\t", "\n", "-->" );
}

1;
