# LexShares Monitor
* size.sh - monitor a file size of the [case portfolio](https://www.lexshares.com/cases) page. If it has changed more than `DELTA` bytes, a notification will be sent to recipients.
* string.sh - parse HTML content of the [case portfolio](https://www.lexshares.com/cases) page. If it contains `STRING`, notifications will be sent to recipients up to `THRESHOLD` times.

Use [SMS Gateway](https://en.wikipedia.org/wiki/SMS_gateway#Email_clients) or [SMS API](https://www.twilio.com/) to send SMS messages to a mobile device.

# Requirements
* cron
* cURL
* msmtp

# Setup
#### msmtp
The major ISPs usually block emails if you try sending directly. To get around the problem, I use msmtp to route my messages through a third-party mail server such as Google, Yahoo, or Spectrum. msmtp is a simple mail transfer agent. It supports SMTP Authentication over TLS/STARTTLS. Follow the steps below to setup msmtp on your system.
```bash
# Install
yum -y install msmtp
useradd -rmd /usr/lib/msmtp msmtp
mkdir /var/log/msmtp
chmod 750 /var/log/msmtp
chown msmtp.msmtp /var/log/msmtp

# Configure
su - msmtp
cat > ~/.msmtprc <EOF
defaults
    tls on
    tls_starttls on
    tls_trust_file /etc/ssl/certs/ca-bundle.crt
    logfile /var/log/msmtp/msmtp.log

account spectrum
    host mail.twc.com
    port 587
    auth on
    user EMAIL_ADDRESS
    password PASSWORD
    from EMAIL_ADDRESS
EOF
chmod 600 ~/.msmtprc

# Test
msmtp -a spectrum me@me.com <<EOF
From: "LexShares Monitor" <monitor@lexshares.com>
To: me@me.com
Subject: LexShares Case Prep Alert!
Content-Type: text/plain; charset=utf-8

Check out the case portfolio at https://www.lexshares.com/cases
EOF

# Check the log
tail -f /var/log/msmtp/msmtp.log
```

#### cron
Set up scheduled tasks to monitor on a regular basis. Adjust the `hour (0 - 23)` and `day of week (0 - 6) (Sunday=0)` for the system time zone. See following examples for `PDT` time (UTC/GMT-07:00).
```bash
# LexShares - File Size Monitoring (M-F 10AM-6PM EST)
*/10 7-15 * * 1-5 /opt/lexshares-monitor/size.sh >/dev/null 2>&1
# LexShares - String Monitoring (M-F 10AM-6PM EST)
*/5 7-15 * * 1-5 /opt/lexshares-monitor/string.sh >/dev/null 2>&1
```
