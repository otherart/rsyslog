#!/bin/bash
# addd 2016-03-22 by RGerhards, released under ASL 2.0
. $srcdir/diag.sh init
. $srcdir/diag.sh generate-conf
. $srcdir/diag.sh add-conf '
$ModLoad ../plugins/imtcp/.libs/imtcp
$InputTCPServerRun 13514

template(name="outfmt" type="string"
	 string="%timereported:::date-rfc3339,date-utc%\n")
:msg, contains, "msgnum:" action(type="omfile" template="outfmt"
			         file="rsyslog.out.log")
'

echo "*** SUBTEST 2003 ****"
rm -f rsyslog.out.log	# do cleanup of previous subtest
. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -M"\"<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 tcpflood 8710 - - msgnum:0000000\""
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
echo "2003-08-24T12:14:15.000003+00:00" | cmp rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid timestamps generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;

echo "*** SUBTEST 2016 ****"
rm -f rsyslog.out.log	# do cleanup of previous subtest
. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -M"\"<165>1 2016-03-01T12:00:00-02:00 192.0.2.1 tcpflood 8710 - - msgnum:0000000\""
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
echo "2016-03-01T14:00:00.000000+00:00" | cmp rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid timestamps generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;

echo "*** SUBTEST 2016 (already in UTC) ****"
rm -f rsyslog.out.log	# do cleanup of previous subtest
. $srcdir/diag.sh startup
. $srcdir/diag.sh tcpflood -m1 -M"\"<165>1 2016-03-01T12:00:00Z 192.0.2.1 tcpflood 8710 - - msgnum:0000000\""
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
echo "2016-03-01T12:00:00.000000+00:00" | cmp rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid timestamps generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;

. $srcdir/diag.sh exit
