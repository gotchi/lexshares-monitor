#!/usr/bin/env bash

# Fail on unset variables and command errors
set -ue -o pipefail

# Prevent commands misbehaving due to locale differences
export LC_ALL=C

# Set PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Monitor Configuration
STRING='View Case Details'
THRESHOLD=1

# Email
USE_EMAIL=true
RECIPIENTS_EMAIL="me@me.com, you@you.com"

# SMS Gateway
USE_SMS=true
RECIPIENTS_SMS="2122222222@txt.att.net, 6466666666@messaging.sprintpcs.com, 3322222222@tmomail.net, 4155555555@vtext.com"

# Twilio
USE_TWILIO=false
RECIPIENTS_TWILIO="2122222222 6466666666 3322222222 4155555555"
TWILIO_FROM=8559108712
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
      sendmail "$RECIPIENTS_EMAIL" <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
Subject: LexShares New Case Alert! - $0 - $COUNTER/$THRESHOLD
Content-Type: text/plain; charset=utf-8

Found the string "$STRING" at https://www.lexshares.com/cases
Hurry up! New Investment Opportunity is available!!
EOF
    fi
    # Send SMS messages via SMS Gateway
    if $USE_SMS; then
      echo "LexShares New Case Alert! - $COUNTER/$THRESHOLD" | sendmail "$RECIPIENTS_SMS"
    fi
    # Send SMS messages via Twilio
    if $USE_TWILIO; then
      for i in $RECIPIENTS_TWILIO
      do
        curl -X POST "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json" \
          --data-urlencode "To=$i" \
          --data-urlencode "From=$TWILIO_FROM" \
          --data-urlencode "Body=LexShares New Case Alert! - $COUNTER/$THRESHOLD" \
          -u ${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}
        sleep 5
      done
    fi
  fi
else
  # Remove the counter file
  [[ -e counter.txt ]] && rm -f counter.txt
fi
