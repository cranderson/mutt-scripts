#!/usr/bin/perl -w
#use HTML::FormatText;
use HTML::Strip;
use HTML::LinkExtor;
#use HTML::LinkExtractor;
use HTML::Entities qw/decode_entities/;
use URI::Escape qw/uri_unescape/;
#use Encode qw/from_to/;

undef $/;
my $html_text = <ARGV>;

my $charset = 'UTF-8';
if ($html_text =~ /\ncontent-type:\s+text\/html;\s+charset=(.*)/i) {
	$charset = $1;
	$charset =~ s/\"//g;
} else {
	#print "no char set\n";
	#print $html_text;
}

#$html_text =~ s/<br>/\n/gi;
#$html_text =~ s/<p>/\n/gi;
my $hs = HTML::Strip->new();
#$hs->clear_striptags();
$hs->set_emit_spaces(0);
my $stripped_text = $hs->parse($html_text);
#my $stripped_text = HTML::FormatText->format_string($html_text, leftmargin => 0, rightmargin => 70);

my $decoded_text = decode_entities($stripped_text);
$decoded_text =~ s/\222/'/g;
$decoded_text =~ s/\226/-/g;
$decoded_text =~ s/\240/ /g;
$decoded_text =~ s/\r//g;
while ($decoded_text =~ s/\n(\s+)\n/\n\n/g) {
	$removed = $1;
}
while ($decoded_text =~ s/\n\n\n+/\n\n/g) {
	$multi_newline = 1;
}
$removed = 0;
$multi_newline = 1;
#$decoded_text = decode($charset, $decoded_text);
###from_to($decoded_text, $charset, 'UTF-8');

my $hl = HTML::LinkExtor->new();
$hl->parse($html_text);
my @links = $hl->links;

#print "Charset: $charset\n";
#print "Message:\n\n";
print $decoded_text;

print "\nLinks:\n\n";
foreach my $link (@links) {
	my $olink = $link;
	if ($$link[2] =~ /^https:\/\/(.+?)\.safelinks\.protection\.outlook\.com\/\?url=(.+?)\&data/) {
	    $$link[2] = $2;
	}
	printf "%-7s %-15s %s\n", $$link[0], $$link[1], uri_unescape($$link[2]);
}
