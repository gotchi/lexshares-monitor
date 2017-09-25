# LexShares Monitor
* size.sh - monitor a file size of the [case opportunities page](https://www.lexshares.com/cases). If it has changed more than `DELTA` bytes, a notification will be sent to `RECIPIENTS`.
* string.sh - parse HTML content of the [case opportunities page](https://www.lexshares.com/cases). If it contains `STRING`, a notification will be sent to `RECIPIENTS_EML` and  `RECIPIENTS_TXT` up to `THRESHOLD` times. Use [SMS Gateway](https://en.wikipedia.org/wiki/SMS_gateway#Email_clients) to send text messages to a mobile device.
# Requirements
* cron
* cURL
* Sendmail
# Setup
Set up a cron job to schedule a task to run on a regular basis. Adjust the `hour (0 - 23)` and `day of week (0 - 6) (Sunday=0)` for the system time zone. See following examples for `PDT` time (UTC/GMT-07:00).
```bash
# LexShares - File Size Monitoring (M-F 9AM-6PM EST)
*/10 6-15 * * 1-5 /opt/lexshares-monitor/size.sh >/dev/null 2>&1
# LexShares - String Monitoring (M-F 9AM-6PM EST)
*/5 6-15 * * 1-5 /opt/lexshares-monitor/string.sh >/dev/null 2>&1
```
