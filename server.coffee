Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = !->

exports.client_lost = (cb) ->