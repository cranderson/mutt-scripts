#!/usr/bin/perl -w
#use HTML::Strip;
#use HTML::LinkExtor;
use HTML::Entities qw/decode_entities/;
use URI::Escape qw/uri_unescape/;
#use Encode qw/from_to/;

sub strip_safelinks($) {
	my $input_text = shift;
	my $output_text;

	if ($input_text =~ /(.*?)https:\/\/(.+?)\.safelinks\.protection\.outlook\.com\/\?url=(.+?)\&data=([^\s]+)(.*)/ms) {
		$first_part = $1;
		#$ms_hostname = $2;
		$orig_url = $3;
		#$url_data = $4;
		$last_part = $5;

		#printf "orig_url = '%s'\n", $orig_url;
		#printf "url_data = '%s'\n", $url_data;

		$output_text = $first_part . uri_unescape($orig_url) . &strip_safelinks($last_part);
	} else {
		$output_text = $input_text;
	}
	return $output_text;
}

undef $/;
my $input_text = <ARGV>;
my $decoded_text = decode_entities($input_text);
$decoded_text =~ s/\r\n/\n/g;
#$decoded_text =~ s/\222/'/g;
#$decoded_text =~ s/\226/-/g;
#$decoded_text =~ s/\240/ /g;
#$decoded_text =~ s/\302/ /g;
print strip_safelinks($decoded_text);
