
# hubot-nagios

hubot-nagios adds [nagios](http://www.nagios.org/) monitoring support to hubot

[![Build Status](https://travis-ci.org/fbernitt/hubot-nagios.png?branch=master)](https://travis-ci.org/fbernitt/hubot-nagios)

## Description

This plugin enables hubot to react to nagios notification as well as request current service state or acknowledge problems.

It requires custom notification commands and a contact on the nagios side as well. On notification nagios runs a simple curl
call to relay the event to hubot. For this to work, hubot needs to listen on an IP that is reachable from nagios.

## Installation and Setup

Add `hubot-nagios` to your package.json, run `npm install` and add hubot-nagios to `external-scripts.json`.

Add hubot-nagios to your `package.json` dependencies.

```
"dependencies": {
  "hubot-nagios": ">= 0.0.1"
}
```

Add `hubot-nagios` to `external-scripts.json`.

```
> cat external-scripts.json
> ["hubot-nagios"]
```

You need to specify the chat room to use for build events and the cctray.xml to use on startup:

    % HUBOT_NAGIOS_EVENT_NOTIFIER_ROOM="#roomname" \
      HUBOT_NAGIOS_URL="https://<username>:<password>@nagioshost.tld/cgi-bin/nagios3" \
      bin/hubot

