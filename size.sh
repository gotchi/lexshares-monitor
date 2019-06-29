#!/usr/bin/env bash

# Fail on unset variables and command errors
set -ue -o pipefail

# Prevent commands misbehaving due to locale differences
export LC_ALL=C

# Set PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Monitor Configuration
DELTA=100
# Email
USE_EMAIL=true
RECIPIENTS_EMAIL="me@me.com"
# SMS Gateway
USE_SMS=false
RECIPIENTS_SMS="2122222222@txt.att.net"
# Twilio
USE_TWILIO=false
RECIPIENTS_TWILIO="2122222222"
TWILIO_FROM=8559108712
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Create directory of log files
LOGFILE=/opt/lexshares-monitor/logs/cases-$(date +%Y%m%d-%H%M%S).html
if [[ ! -d $(dirname $LOGFILE) ]]; then
  mkdir -p $(dirname $LOGFILE)/assets
fi

# Retrieve the case listing
curl -s -o $LOGFILE https://www.lexshares.com/cases

# a 'first run' check
if [[ ! -f last ]]; then
  stat -c %s $LOGFILE > last
  rm -f $LOGFILE
  exit 0
fi

# Compare the file size
OLD_SIZE=$(cat last)
NEW_SIZE=$(stat -c %s $LOGFILE)

if [[ $((NEW_SIZE-OLD_SIZE))**2 -gt $((DELTA**2)) ]]; then
  # Retry
  curl -s -o RETRY https://www.lexshares.com/cases
  RETRY_SIZE=$(stat -c %s RETRY)
  if [[ $((RETRY_SIZE-OLD_SIZE))**2 -gt $((DELTA**2)) ]]; then
    # Send emails
    if $USE_EMAIL; then
        sendmail "$RECIPIENTS_EMAIL" <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
Subject: LexShares Case Prep Alert! - $0
Content-Type: text/plain; charset=utf-8

File size has changed:
------
http://lex.rentier.us/$(basename $LOGFILE_OLD): $LOGSIZE_OLD bytes
http://lex.rentier.us/$(basename $LOGFILE): $LOGSIZE bytes

Check out the case portfolio at https://www.lexshares.com/cases
If the page has updated, a new case is in the pipeline.
EOF
    fi
    # Send SMS messages via SMS Gateway
    if $USE_SMS; then
      echo "LexShares Case Prep Alert! - $0" | sendmail "$RECIPIENTS_SMS"
    fi
    # Send SMS messages via Twilio
    if $USE_TWILIO; then
      for i in $RECIPIENTS_TWILIO
      do
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json \
          --data-urlencode "Body=LexShares Case Prep Alert! - $0" \
          --data-urlencode "From=$TWILIO_FROM" \
          --data-urlencode "To=$i" \
          -u ${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}
        sleep 5
      done
    fi
    # Save a .css file
    CSS=$(grep -o application-.*css $LOGFILE)
    curl -s -o $(dirname $LOGFILE)/assets/${CSS} https://www.lexshares.com/assets/${CSS}
    stat -c %s $LOGFILE > last
  else
    rm -f $LOGFILE
  fi
  rm -f RETRY
else
  stat -c %s $LOGFILE > last
  rm -f $LOGFILE
fi
