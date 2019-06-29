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
EMAIL_TO="me@me.com"
# SMS Gateway
USE_SMS=false
SMS_TO="2122222222@txt.att.net"
# Twilio
USE_TWILIO=false
TWILIO_FROM=8559108712
TWILIO_TO="2122222222"
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Create a log directory
LOGFILE=/opt/lexshares-monitor/logs/cases-$(date +%Y%m%d-%H%M%S).html
if [[ ! -d $(dirname $LOGFILE) ]]; then
  mkdir -p $(dirname $LOGFILE)/assets
fi

# Retrieve the case listing page
curl -s -o $LOGFILE https://www.lexshares.com/cases

# a 'first run' check
if [[ ! -f last ]]; then
  stat -c %s $LOGFILE > last
  rm -f $LOGFILE
  exit 0
fi

# Compare 2 file sizes
OLD_SIZE=$(cat last)
NEW_SIZE=$(stat -c %s $LOGFILE)

if [[ $((NEW_SIZE-OLD_SIZE))**2 -gt $((DELTA**2)) ]]; then
  # Retry
  curl -s -o RETRY https://www.lexshares.com/cases
  RETRY_SIZE=$(stat -c %s RETRY)
  if [[ $((RETRY_SIZE-OLD_SIZE))**2 -gt $((DELTA**2)) ]]; then
    # Send emails
    if $USE_EMAIL; then
        sendmail "$EMAIL_TO" <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
Subject: LexShares Case Prep Alert!
Content-Type: text/plain; charset=utf-8

File size has changed:
------
Previous: $OLD_SIZE bytes
Current:  $NEW_SIZE bytes
Retry:    $RETRY_SIZE bytes

Check out the case portfolio at https://www.lexshares.com/cases
If the page has updated, a new case is in the pipeline.
EOF
    fi
    # Send SMS messages via SMS Gateway
    if $USE_SMS; then
      echo "LexShares Case Prep Alert!" | sendmail "$SMS_TO"
    fi
    # Send SMS messages via Twilio
    if $USE_TWILIO; then
      for i in $TWILIO_TO
      do
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json \
          --data-urlencode "Body=LexShares Case Prep Alert!" \
          --data-urlencode "From=$TWILIO_FROM" \
          --data-urlencode "To=$i" \
          -u ${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}
        # Twilio imposes rate restrictions for local number
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
