Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.client_newVergadering = (naam, cb) !->
	date = new Date()
	id = Db.shared.modify 'vergaderingenID', (v) -> (v||0)+1
	
	Db.shared.set 'vergaderingen', id, {naam: naam, datum: date, actiepuntenID: 0}
	
	log 'user ', Plugin.userName(), '(', Plugin.userId(), ') added meeting "', naam, '" (', id, ')'
	cb.reply id


exports.client_newActiepunt = (vergadering, naam, persoon, cb) !->
	date = new Date()
	status = 1
	id = Db.shared.modify 'vergaderingen', vergadering, 'actiepuntenID', (v) -> (v||0)+1
	
	Db.shared.set 'vergaderingen', vergadering, 'actiepunten', id, {naam: naam, persoon: persoon, status: status, datum: date}
	
	log 'user ', Plugin.userName(), '(', Plugin.userId(), ') added actiepunt "', naam, '" (', id, ') to meeting ', vergadering
	cb.reply id


exports.client_updateActiepunt = (vID, aID, cb) !->
	actiepunt = Db.shared.get('vergaderingen', vID, 'actiepunten', aID)
	if(!actiepunt)
		cb.reply "false"
	else
		Db.shared.modify 'vergaderingen', vID, 'actiepunten', aID, 'status', (s) -> (s+1)%4
		cb.reply aID