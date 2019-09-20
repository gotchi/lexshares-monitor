#!/usr/bin/env bash

# Fail on unset variables and command errors
set -ue -o pipefail

# Prevent commands misbehaving due to locale differences
export LC_ALL=C

# Set PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Monitor Configuration
STRING='Join to access'
THRESHOLD=3
# msmtp
MSMTP_CONFIG=/usr/lib/msmtp/.msmtprc
MSMTP_ACCOUNT=spectrum
# Email
USE_EMAIL=false
EMAIL_TO="me@me.com you@you.com"
# SMS Gateway
USE_SMS=false
SMS_TO="2122222222@txt.att.net 6466666666@messaging.sprintpcs.com 3322222222@tmomail.net 4155555555@vtext.com"
# Twilio
USE_TWILIO=false
TWILIO_FROM=8559108712
TWILIO_TO="2122222222 6466666666 3322222222 4155555555"
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Check the string
if curl -s https://www.lexshares.com/cases | grep -i "$STRING"; then
  # Increment the counter
  if [[ -f counter.txt ]]; then
    COUNTER=$(cat counter.txt)
    let COUNTER++
  else
    COUNTER=1
  fi
  echo $COUNTER > counter.txt

  if [[ "$COUNTER" -le "$THRESHOLD" ]]; then
    # Send emails
    if $USE_EMAIL; then
      for recipient in $EMAIL_TO
      do
        msmtp -C $MSMTP_CONFIG -a $MSMTP_ACCOUNT $recipient <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
To: $recipient
Subject: LexShares New Case Alert! - $COUNTER/$THRESHOLD
Content-Type: text/plain; charset=utf-8

Found the string "$STRING" at https://www.lexshares.com/cases
A new investment opportunity is now available!!
EOF
        sleep 1
      done
    fi
    # Send SMS messages via SMS Gateway
    if $USE_SMS; then
      for recipient in $SMS_TO
      do
        msmtp -C $MSMTP_CONFIG -a $MSMTP_ACCOUNT $recipient <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
To: $recipient
Subject: LexShares New Case Alert! - $COUNTER/$THRESHOLD
Content-Type: text/plain; charset=utf-8

Request to view the case details at https://www.lexshares.com/cases
EOF
        sleep 1
      done
    fi
    # Send SMS messages via Twilio
    if $USE_TWILIO; then
      for recipient in $TWILIO_TO
      do
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json \
          --data-urlencode "From=$TWILIO_FROM" \
          --data-urlencode "To=$recipient" \
          --data-urlencode "Body=LexShares New Case Alert! - $COUNTER/$THRESHOLD" \
          -u ${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}
        # Twilio imposes rate restrictions for local number
        sleep 5
      done
    fi
  fi
else
  # Remove the counter file
  [[ -e counter.txt ]] && rm -f counter.txt
fi
