Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.client_newVergadering = (naam, cb) !->
	date = new Date()
	id = Db.shared.modify 'vergaderingenID', (v) -> (v||0)+1
	
	Db.shared.set 'vergaderingen', id, {naam: naam, datum: date, actiepuntenID: 0}
	
	log 'user ', Plugin.userName(), '(', Plugin.userId(), ') added meeting "', naam, '" (', id, ')'
	cb.reply id
exports.client_newActiepunt = (naam, persoon, cb) !->
	date = new Date()
	status = 0;