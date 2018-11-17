# mutt-scripts
Scripts and configurations for Mutt

Use striphtmlsafelinks.pl and stripsafelinks.pl like this:

In .muttrc:

    set mailcap_path = ~/.muttmailcap
    auto_view text/plain
    auto_view text/html
    auto_view text/calendar

In .muttmailcap:

    text/plain; /path/to/stripsafelinks.pl %{charset}; copiousoutput
    text/html; /path/to/striphtmlsafelinks.pl %{charset}; copiousoutput
    text/calendar; /home/cra/bin/vcalendar-filter; copiousoutput

However, I've since abandoned the HTML::Strip striphtmlsafelinks.pl script
in favor of w3m instead.  I still use stripsafelinks.pl with w3m as follows:

    text/html; w3m -dump -s -o display_link=yes -o display_link_number=yes -o decode_url=yes -T text/html -I %{charset} | /path/to/stripsafelinks.pl UTF-8; copiousoutput; description=HTML Text
