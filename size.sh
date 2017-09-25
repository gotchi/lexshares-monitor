#!/usr/bin/env bash

# Fail on unset variables and command errors
set -ue -o pipefail

# Prevent commands misbehaving due to locale differences
export LC_ALL=C

# Set PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Variables
RECIPIENTS="me@me.com"
DELTA=100

# Create directory of log files
LOGFILE=/opt/lexshares-monitor/logs/cases-$(date +%Y%m%d-%H%M%S).html
if [[ ! -d "$(dirname "$LOGFILE")" ]]; then
  mkdir -p "$(dirname "$LOGFILE")"
fi
LOGFILE_OLD=$(find "$(dirname "$LOGFILE")" -name "*.html" | sort | tail -1)

# Retrieve the case listing
curl -s -o "$LOGFILE" https://www.lexshares.com/cases

# Check the file size
if [[ -n $LOGFILE_OLD ]]; then
  LOGSIZE_OLD=$(stat -c %s "$LOGFILE_OLD")
  LOGSIZE=$(stat -c %s "$LOGFILE")
else
  exit 0
fi

# Compare the file size
if [[ $((LOGSIZE-LOGSIZE_OLD)) -gt $DELTA ]] || [[ $((LOGSIZE_OLD-LOGSIZE)) -gt $DELTA ]]; then
  sendmail "$RECIPIENTS" <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
Subject: LexShares Case Prep Alert! - $0
Content-Type: text/plain; charset=utf-8

File size has changed:
------
$LOGFILE_OLD: $LOGSIZE_OLD bytes
$LOGFILE: $LOGSIZE bytes

Check out the website at https://www.lexshares.com/cases
If the content on the page has changed, LexShares is preparing for a new case!
EOF
fi
