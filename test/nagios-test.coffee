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

fs = require 'fs'
chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
querystring = require 'querystring'
path = require 'path'

HttpClient = require 'scoped-http-client'

expect = chai.expect

hubot = require 'hubot'

User = require 'hubot/src/user'
{TextMessage} = require 'hubot/src/message'

exports.helper = ->
  new TestRobot("#{__dirname}/scripts")


class TestAdapter extends hubot.Adapter
  send: (user, strings...) ->
    @robot.sent.push str for str in strings
    @robot.recipients.push user for str in strings
    @cb? strings...

  reply: (user, strings) ->
    @send user, "#{@robot.name}: #{str}" for str in strings

  receive: (text) ->
    if typeof text is 'string'
      user = new User 1, 'helper'
      super new TextMessage user, text
    else
      super text

class TestRobot extends hubot.Robot
  loadAdapter: (path, adapter) ->
    return path

  constructor: (scriptPath) ->
    super null, null, true, 'hubot'
    @load scriptPath
    @id = 1
    @Response = TestRobot.Response
    @sent = []
    @recipients = []
    @adapter = new TestAdapter @
    @alias = 'alias'
    @loadAdapter = (path, adapter) ->
      return path


  receive: (message) ->
    super message


  hear: (message, cb) ->
    super message, cb

  reset: ->
    @sent = []
    @recipients = []


class TestRobot.Response extends hubot.Response
  http: (url) ->
    super(url).host('127.0.0.1').port(9001)

describe 'nagios', ->
  mock_robot =
  scripts_path = path.join(__dirname, '..', 'src', 'scripts')
  bot = new TestRobot(scripts_path)
  process.env.HUBOT_NAGIOS_EVENT_NOTIFIER_ROOM = '#someroom'

  beforeEach ->
    bot.reset()
    router =
      post: sinon.spy()
    brain =
      data: sinon.spy()
    mock_robot =
      brain: brain
      router: router
      respond: sinon.spy()
      hear: sinon.spy()
      send: sinon.spy()
      messageRoom: sinon.spy()

    nagios = require('../src/scripts/nagios')(mock_robot)

  it 'should activate a webhook for host notifications', ->
    expect(mock_robot.router.post).to.have.been.calledWith('/hubot/nagios/host', sinon.match.func)

  it 'should reply with OK to test', ->
    bot.adapter.receive "test"
    expect(bot.sent.length).to.equal(1)
    expect(bot.sent[0]).to.equal('OK')

  it 'should react to host post messages', (done) ->
    bot.brain.data.nagios_event_room = '#testroom'
    data = querystring.stringify({host: 'test',
    notificationtype: 'PROBLEM',
    hostoutput: 'Something is CRITICAL'})

    HttpClient.create("http://localhost:8080/hubot/nagios/host").header('Content-Type', 'application/x-www-form-urlencoded').post(data) (err, res, body) ->
      expect(bot.sent.length).to.equal(1)
      expect(bot.sent[0]).to.equal('nagios PROBLEM: test is Something is CRITICAL')
      expect(bot.recipients.length).to.equal(1)
      expect(bot.recipients[0]).to.eql({room: "#testroom"})
      done()

  it 'should react to service post messages', (done) ->
    bot.brain.data.nagios_event_room = '#testroom'
    data = querystring.stringify({host: 'test',
    servicedescription: 'some_service',
    servicestate: 'STATE',
    notificationtype: 'PROBLEM',
    serviceoutput: 'Some service is CRITICAL'})

    HttpClient.create("http://localhost:8080/hubot/nagios/service").header('Content-Type', 'application/x-www-form-urlencoded').post(data) (err, res, body) ->
      expect(bot.sent.length).to.equal(1)
      expect(bot.sent[0]).to.equal('nagios PROBLEM: test:some_service is STATE: Some service is CRITICAL')
      expect(bot.recipients.length).to.equal(1)
      expect(bot.recipients[0]).to.eql({room: "#testroom"})
      done()
