#!/usr/bin/perl

use warnings;
use strict;
use lib ".";
use releasepackager;
use filemanager;
use billofmaterials;
use logger;
use utils;

sub main()
{	
	print "Create Instance of FileManager [press enter]\n";
	<STDIN>;
	FileManager->new();

	print "read ignore list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->readIgnoreList();

	print "print ignore list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->printIgnoreList();

	print "read exception list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->readExceptionList();

	print "print exception list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->printExceptionList();

	print "get license list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->getLicenseList();

	print "print license list [press enter]\n";
	<STDIN>;
	BillOfMaterials->new()->printLicenseList();

	print "read directory contents to array [press enter]\n";
	<STDIN>;
	FileManager->new()->getDirectory( $Utils::sourcePath );

	print "Print directory contents [press enter]\n";
	<STDIN>;
	print "FILES FOUND IN $Utils::sourcePath AND ITS SUBDIRECTORIES\n\n";
	FileManager->new()->printFilesList();

	print "Change Files [press enter]\n";
	<STDIN>;
	FileManager->new()->changeFiles();

	print "Tidy the Wind River log file? [y/n]\n";
	chomp(my $response = <STDIN>);
	if($response eq 'y')
	{
		Logger->new->tidy();
		#system("grep -v -B 1 "*@windriver\.com" FileManager->new()->readFile( Logger->new->{ _windLogFilePath } ");
	}

}

main();
