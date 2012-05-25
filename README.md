# PagerDuty Incident Webhooks

This fires a webhook of incident data for each triggered incident PagerDuty in your account. Ideally, you'd point this at another tiny app that processes the events and does your bidding with them - ships them to campfire, APN, a tiny sinatra app that pipes incidents to `say`...go nuts.

Re-triggered incidents will cause an additional webhook to be sent for the same incident. Make sure your endpoint is okay with this.

I hate to poll like this, but [whatever](http://feedback.pagerduty.com/forums/18293-general/suggestions/306514-support-webhooks-as-a-notification-method). It works.

## Running on Heroku

Clone this repo.

In the clone:

    heroku create --stack cedar yourname-pagerduty-incident-webhooks --addons memcache heroku papertrail:test


Set the following config at heroku:

    heroku config:add PAGERDUTY_ACCOUNT_SUBDOMAIN=foo
    heroku config:add PAGERDUTY_AUTH_EMAIL=foo@foo.com
    heroku config:add PAGERDUTY_AUTH_PASSWORD=foo
    heroku config:add PAGERDUTY_WEBHOOK_ENDPOINT=http://requestb.in/1e88aqp1
    heroku config:add POLL_INTERVAL=10

Ship it:

    git push heroku master

Fire up a web process:

    heroku scale web=1

Hit up [papertrail](https://papertrailapp.com/events) and check on the logs.

## Credit where Credit is Due

Large parts of this are based on the PagerDuty library [@leejones](https://github.com/leejones) wrote for [pager_today](https://github.com/railsmachine/pager_today).

Copying
-------

Copyright 2012, GitHub, Inc. See the `LICENSE` file for license rights and limitations (MIT).