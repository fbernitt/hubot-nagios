
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
      bin/hubot

Within nagios configuration you need to add a new contact that calls the hubot webhook:

```
define contact {
        alias                          hubot
        host_notification_period       24x7
        service_notification_options   w,u,c,r
        contact_name                   hubot
        email                          someone@somedomain.tld
        host_notification_options      d,r
        service_notification_period    24x7
        service_notification_commands  notify-service-by-hubot
        host_notification_commands     notify-host-by-hubot
}
```

And add this new contact as a member to at least one contactgroup.


You need to add these new commands:
```
define command {
        command_name                    notify-service-by-hubot
        command_line                    /usr/bin/curl -d host="$HOSTALIAS$" -d serviceoutput="$SERVICEOUTPUT$" -d servicedescription="$SERVICEDESC$" -d notificationtype="$NOTIFICATIONTYPE$" -d servicestate="$SERVICESTATE$" https://username:password@hubot.somedomain.tld/hubot/nagios/service
}

define command {
        command_name                    notify-host-by-hubot
        command_line                    /usr/bin/curl -d host="$HOSTNAME$" -d hostoutput="$HOSTOUTPUT$" -d notificationtype="$NOTIFICATIONTYPE$" -d hoststate="$HOSTSTATE$" https://username:password@hubot.somedomain.tld/hubot/nagios/host
}
```

That's it!

