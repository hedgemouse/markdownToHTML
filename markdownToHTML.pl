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

our $list_count_unordered = 0;
our $list_count_ordered = 0;
while (<$mdFile>) {
	my $text = $_;
	my $header_count = ($_ =~ tr/\#//);
	my $isList = "false";

	# Unordered list
	if ($text =~ m/^\-\s/) {
		$isList = "true";
		if ($list_count_unordered == 0) {
			print $htmlFile "\t\t<ul>\n"; # start of an unordered list
			$list_count_unordered = 1;
		} else {
			$list_count_unordered += 1;
		}
	} elsif ($list_count_unordered > 0) {
		$list_count_unordered = 0;
		print $htmlFile "\t\t</ul>\n"; # end of an unordered list
	}
	$text =~ s/^\-\s(.+)/\<li\>$1\<\/li\>/; # list item (unordered list)

	# Ordered list
	if ($text =~ m/^\d\.\s/) {
		$isList = "true";
		if ($list_count_ordered == 0) {
			print $htmlFile "\t\t<ol>\n"; # start of an ordered list
			$list_count_ordered = 1;
		} else {
			$list_count_ordered += 1;
		}
	} elsif ($list_count_ordered > 0) {
		$list_count_ordered = 0;
		print $htmlFile "\t\t</ol>\n"; # end of an ordered list
	}
	$text =~ s/^\d\.\s(.+)/\<li\>$1\<\/li\>/; # list item (ordered list)

	if ($header_count > 0) {
		$text =~ s/^\#{$header_count}\s(.+)/\<h$header_count\>$1\<\/h$header_count\>/; # header
	}
	$text =~ s/\*\*([^*]+)\*\*/\<b\>$1\<\/b\>/; # bold
	$text =~ s/\*([^*]+)\*/\<i\>$1\<\/i\>/; # italic
	$text =~ s/\!\[(.+)\]\((.+)\)/\<img\ src\=\"$2\"\ alt\=\"$1\"\>/; # image
	$text =~ s/\[(.+)\]\((.+)\)/\<a\ href\=\"$2\"\>$1\<\/a\>/; # link

	$text = removeNewLine($text);
	if ($text eq "") {
		next;
	}
	if (isHeader($text) eq "true") {
		print $htmlFile "\t\t$text\n";
	} elsif ($isList eq "true") {
		print $htmlFile "\t\t\t$text\n";
	} else {
		print $htmlFile "\t\t<p>$text</p>\n";
	}
}

print $htmlFile "\t</body>\n" .
"</html>\n";
