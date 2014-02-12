#
# Regular cron jobs for the cryptopp package
#
0 4	* * *	root	[ -x /usr/bin/cryptopp_maintenance ] && /usr/bin/cryptopp_maintenance
