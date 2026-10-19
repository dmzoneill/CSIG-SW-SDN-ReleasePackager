#!/usr/bin/perl

use warnings;
use strict;

package CopyingLicenseStrategy;
use LicenseStrategy;
our @ISA = ( "LicenseStrategy" );

sub headerPattern
{
	return '^Copyright.*?Wind River.*?Wind River.*?\n';
}

sub headerSearchLog
{
	return "replace copying: ";
}

sub headerReplacedLog
{
	return "REPLACED COPYING: ";
}

sub logLicenseSelection
{
	return 1;
}

1;
