#!/usr/bin/env bash

# Fail on unset variables and command errors
set -ue -o pipefail

# Prevent commands misbehaving due to locale differences
export LC_ALL=C

# Set PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Variables
RECIPIENTS_EML="me@me.com, you@you.com"
RECIPIENTS_TXT="8088888888@txt.att.net, 2129999999@vtext.com"
STRING='View Case Details'
THRESHOLD=3

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
    # Notify Email
    sendmail "$RECIPIENTS_EML" <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
Subject: LexShares New Case Alert! - $0 - $COUNTER/$THRESHOLD
Content-Type: text/plain; charset=utf-8

Found the string "$STRING" at https://www.lexshares.com/cases
Hurry up! New Investment Opportunity is available!!
EOF
    # Notify SMS Gateway
    echo "LexShares New Case Alert! - $COUNTER/$THRESHOLD" | sendmail "$RECIPIENTS_TXT"
  fi
else
  # Remove the counter file
  [[ -e counter.txt ]] && rm -f counter.txt
fi
