#!/usr/bin/perl
use strict;
use warnings;

my ($arg1) = @ARGV;

open(my $mdFile, "<", $arg1) or die "Error opening $arg1: $!\n";

my $htmlFile_name = $arg1;
$htmlFile_name =~ s/md$/html/;
open(my $htmlFile, ">", $htmlFile_name) or die "Error opening $htmlFile_name: $!\n";

my $title = $arg1;
$title =~ s/\.md$//;
$title =~ s/^([a-z])/\u$1/;
print $htmlFile 
"<!DOCTYPE html>\n" .
"<html>\n" .
	"\t<head>\n" .
		"\t\t<title>$title</title>\n" .
		"\t\t<meta charset=\"UTF-8\">\n" .
	"\t</head>\n" .
	"\t<body>\n";

sub removeNewLine {
	my $return_value = $_[0];
	$return_value =~ s/\n$//;
	return($return_value);
}

sub isHeader {
	if ($_[0] =~ m/\<h\d\>/) {
		return("true");
	}
	return("false");
}

while (<$mdFile>) {
	my $text = $_;
	my $header_count = ($_ =~ tr/\#//);
	if ($header_count) {
		$text =~ s/^\#{$header_count}\s(.+)/\<h$header_count\>$1\<\/h$header_count\>/;
	}
	if ($_ =~ m/\*\*[^*]+\*\*/) { # bold
		$text =~ s/\*\*([^*]+)\*\*/\<b\>$1\<\/b\>/;
	}
	if ($_ =~ m/\*[^*]+\*/) { # italic
		$text =~ s/\*([^*]+)\*/\<i\>$1\<\/i\>/;
	}
	$text = removeNewLine($text);
	if ($text eq "") {
		next;
	}
	if (isHeader($text) eq "true") {
		print $htmlFile "\t\t$text\n";
	} else {
		print $htmlFile "\t\t<p>$text</p>\n";
	}
}

print $htmlFile "\t</body>\n" .
"</html>\n";
