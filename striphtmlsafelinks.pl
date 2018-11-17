#!/usr/bin/perl -w
# Strip all HTML from STDIN, converting the input to plain text.
# Also extract the real URL from all Microsoft "safelinks".
#
# Call from mailcap like this:
# text/html; /path/to/striphtmlsafelinks.pl %{charset}; copiousoutput

# Have perl treat strings as Unicode internally
use feature 'unicode_strings';

# Mutt passes the encoding of the email as the first argument
my $charset = $ARGV[0];

# Have perl convert all STDIN input from the given encoding
# to UTF-8 and also output to STDOUT as UTF-8.
binmode \*STDIN, ":encoding($charset)";
binmode \*STDOUT, ':encoding(UTF-8)';

#use HTML::FormatText;
use HTML::Strip;
use HTML::LinkExtor;
#use HTML::LinkExtractor;
use HTML::Entities qw/decode_entities/;
use URI::Escape qw/uri_unescape/;
#use Encode qw/from_to/;

# Suck in entire HTML email at once
undef $/;
my $html_text = <STDIN>;

# Apply fix-ups to the HTML
$html_text =~ s/&nbsp;/ /g; # Replace non-breaking spaces with standard spaces

# Strip HTML tags leaving just plain text
my $hs = HTML::Strip->new();
#$hs->clear_striptags();
$hs->set_emit_spaces(0);
my $stripped_text = $hs->parse($html_text);
#my $stripped_text = HTML::FormatText->format_string($html_text, leftmargin => 0, rightmargin => 70);

# Decode any remaining HTML Entities
my $decoded_text = decode_entities($stripped_text);

# Apply fix-ups to the plain text
$decoded_text =~ s/\r\n/\n/g;		# Convert line endings from DOS to Unix (CRLF to LF)
$decoded_text =~ s/\n(\s+)\n/\n\n/g;	# Remove blank spaces in otherwise empty lines
$decoded_text =~ s/\n\n\n+/\n\n/g;	# Collapse multiple blank lines to one

my $hl = HTML::LinkExtor->new();
$hl->parse($html_text);
my @links = $hl->links;

print $decoded_text;

print "\nLinks:\n\n";
foreach my $link (@links) {
	my $olink = $link;
	if ($$link[2] =~ /^https:\/\/(.+?)\.safelinks\.protection\.outlook\.com\/\?url=(.+?)\&data/) {
	    $$link[2] = $2;
	}
	printf "%-7s %-15s %s\n", $$link[0], $$link[1], uri_unescape($$link[2]);
}
