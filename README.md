# mutt-scripts
Scripts and configurations for Mutt

Use striphtmlsafelinks.pl and stripsafelinks.pl like this:

In .muttrc:

  set mailcap_path = ~/.muttmailcap

In .muttmailcap:

  text/plain; /home/cra/bin/stripsafelinks.pl; copiousoutput
  text/html; /home/cra/bin/striphtmlsafelinks.pl; copiousoutput
  text/calendar; /home/cra/bin/vcalendar-filter; copiousoutput
