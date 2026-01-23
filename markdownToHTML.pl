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
print $htmlFile "<!DOCTYPE html>\n" . "<html>\n" . "<head>\n" . "\t<title>$title</title>\n" . "</head>\n" . "<body>\n";

sub removeNewLine {
	my $return_value = $_[0];
	$return_value =~ s/\n$//;
	return($return_value);
}

while (<$mdFile>) {
	my $count_header = ($_ =~ tr/\#//);
	if ($count_header) {
		my $text = $_;
		$text =~ s/\#{$count_header}\s//;
		$text = removeNewLine($text);
		print $htmlFile "\t<h$count_header>$text</h$count_header>\n";
	}
	if ($_ =~ m/\*[^\*]+\*[^\*]/) {
		my $text = $_;
		$text =~ s/\*(.+)\*/\<i\>$1\<\/i\>/;
		$text = removeNewLine($text);
		print $htmlFile "\t$text\n\t<br>\n";
	}
	if ($_ =~ m/\*\*[^\*]+\*\*[^\*]/) {
		my $text = $_;
		$text =~ s/\*\*(.+)\*\*/\<b\>$1\<\/b\>/;
		$text = removeNewLine($text);
		print $htmlFile "\t$text\n\t<br>\n";
	}
}

print $htmlFile "</body>\n" . "</html>\n";
