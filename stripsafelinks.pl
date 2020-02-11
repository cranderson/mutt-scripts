#!/usr/bin/perl -w
# Extract and output the real URL from all Microsoft "safelinks".
#
# Call from mailcap like this:
# text/plain; /path/to/stripsafelinks.pl %{charset}; copiousoutput

# Have perl treat strings as Unicode internally
use feature 'unicode_strings';

# Recursion level of stripsafelinks function
my $level = 0;

# Mutt passes the encoding of the email as the first argument
my $charset = $ARGV[0];
$charset = 'UTF-8' if ($charset eq '___utf-8___' or $charset eq 'unknown-8bit');

# Have perl convert all STDIN input from the given encoding
# to UTF-8 and also output to STDOUT as UTF-8.
binmode \*STDIN, ":encoding($charset)";
binmode \*STDOUT, ':encoding(UTF-8)';

use HTML::Entities qw/decode_entities/;
use URI::Escape qw/uri_unescape/;

# Recursive function to strip safelinks
sub strip_safelinks($) {
	my $input_text = shift;
	my $output_text;
	$level++;

	# limit recrusion to 50 levels
	if ($level <= 50 && $input_text =~ /(.*?)https:\/\/(.+?)\.safelinks\.protection\.outlook\.com\/\?url=(.+?)\&data=([^\s]+)(.*)/ms) {
		my $first_part = $1;
		#my $ms_hostname = $2;
		my $orig_url = $3;
		#my $url_data = $4;
		my $last_part = $5;

		#printf "orig_url = '%s'\n", $orig_url;
		#printf "url_data = '%s'\n", $url_data;

		$output_text = $first_part . uri_unescape($orig_url) . &strip_safelinks($last_part);
	} else {
		$output_text = $input_text;
		$level = 0;
	}
	return $output_text;
}

# Suck in entire text email at once
#undef $/;
#my $input_text = <STDIN>;

# Process email one line at a time
while(<STDIN>) {
	# Decode HTML entities, convert DOS to Unix line endings,
	# and strip the safelinks.
	my $decoded_text = decode_entities($_);
	$decoded_text =~ s/\r\n/\n/g;
	print strip_safelinks($decoded_text);
}
