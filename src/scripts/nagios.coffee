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
  robot.brain.data.nagios_event_room = room

  robot.router.post '/hubot/nagios/host', (request, response) ->
    host = request.body.host
    hostOutput = request.body.hostoutput
    notificationType = request.body.notificationtype
    announceNagiosHostMessage host, hostOutput, notificationType, (msg) ->
      robot.messageRoom event_room(robot), msg

    response.end ""

  robot.router.post '/hubot/nagios/service', (request, response) ->
    host = request.body.host
    serviceOutput = request.body.serviceoutput
    notificationType = request.body.notificationtype
    serviceDescription = request.body.servicedescription
    serviceState = request.body.servicestate

    announceNagiosServiceMessage host, notificationType, serviceDescription, serviceState, serviceOutput, (msg) ->
      robot.messageRoom event_room(robot), msg

    response.end ""

event_room = (robot) ->
  return robot.brain.data.nagios_event_room

announceNagiosHostMessage = (host, hostOutput, notificationType, cb) ->
  cb "nagios #{notificationType}: #{host} is #{hostOutput}"

announceNagiosServiceMessage = (host, notificationType, serviceDescription, serviceState, serviceOutput, cb) ->
  cb "nagios #{notificationType}: #{host}:#{serviceDescription} is #{serviceState}: #{serviceOutput}"
