# PagerDuty Incident Webhooks

This fires a webhook of incident data for each triggered incident PagerDuty in your account. Ideally, you'd point this at another tiny app that processes the events and does your bidding with them - ships them to campfire, APN, whatever.

Re-triggered incidents will cause an additional webhook to be sent for the same incident. Make sure your endpoint is okay with this.

I hate to poll like this, but [whatever](http://feedback.pagerduty.com/forums/18293-general/suggestions/306514-support-webhooks-as-a-notification-method). It works.

## Running on Heroku

Clone this repo.

In the clone:

    heroku create --stack cedar yourname-pagerduty-incident-webhooks --addons memcache

Set the following config at heroku:

    heroku config:add PAGERDUTY_ACCOUNT_SUBDOMAIN=foo
    heroku config:add PAGERDUTY_AUTH_EMAIL=foo@foo.com
    heroku config:add PAGERDUTY_AUTH_PASSWORD=foo
    heroku config:add PAGERDUTY_WEBHOOK_ENDPOINT=http://www.postbin.org/adsfasd

Ship it:

    git push heroku master

Fire up a web process:

    heroku scale web=1

Verify it works:

    heroku logs -t