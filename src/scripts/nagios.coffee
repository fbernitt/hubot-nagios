# Copyright 2015 Folker Bernitt
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

room = process.env.HUBOT_NAGIOS_EVENT_NOTIFIER_ROOM
nagiosUrl = process.env.HUBOT_NAGIOS_URL

module.exports = (robot) ->

  robot.router.post '/hubot/nagios/host', (request, response) ->
    host = request.body.host
    hostOutput = request.body.hostoutput
    notificationType = request.body.notificationtype

    announceNagiosHostMessage host, hostOutput, notificationType, (msg) ->
      robot.messageRoom room, msg

    response.end ""

  robot.router.post '/hubot/nagios/service', (request, response) ->
    response.end ""


announceNagiosHostMessage = (host, hostOutput, notificationType, cb) ->
    cb "nagios #{notificationType}: #{host} is #{hostOutput}"
