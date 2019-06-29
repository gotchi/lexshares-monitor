# LexShares Monitor
* size.sh - monitor a file size of the [case portfolio](https://www.lexshares.com/cases) page. If it has changed more than `DELTA` bytes, a notification will be sent to recipients.
* string.sh - parse HTML content of the [case portfolio](https://www.lexshares.com/cases) page. If it contains `STRING`, notifications will be sent to recipients up to `THRESHOLD` times.

Use [SMS Gateway](https://en.wikipedia.org/wiki/SMS_gateway#Email_clients) or [SMS API](https://www.twilio.com/) to send SMS messages to a mobile device.

# Requirements
* cron
* cURL
* Sendmail

# Setup
Set up scheduled tasks to monitor on a regular basis. Adjust the `hour (0 - 23)` and `day of week (0 - 6) (Sunday=0)` for the system time zone. See following examples for `PDT` time (UTC/GMT-07:00).
```bash
# LexShares - File Size Monitoring (M-F 10AM-6PM EST)
*/10 7-15 * * 1-5 /opt/lexshares-monitor/size.sh >/dev/null 2>&1
# LexShares - String Monitoring (M-F 10AM-6PM EST)
*/5 7-15 * * 1-5 /opt/lexshares-monitor/string.sh >/dev/null 2>&1
```
