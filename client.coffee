Dom = require 'dom'
Server = require 'server'
Ui = require 'ui'
Db = require 'db'
Plugin = require 'plugin'
Page = require 'page'
Form = require 'form'
Modal = require 'modal'
{tr} = require 'i18n'

exports.render = ->
	p = Page.state.get(0)
	if p == 'newVergadering'
		# Adding a new meeting
		
		# Submit form
		Form.setPageSubmit (values) !->
			naam = values.naam.trim()
			if !naam
				Modal.show 'U heeft geen titel ingevuld'
			else
				# Save new meeting
				Server.call 'newVergadering', naam, (res)->
					if res == "false"
						Modal.show 'Er iets mis gegaan, probeer het later nog eens'
					else
						Page.nav res
		
		
		# Form for filling the name
		Dom.div !->
			Dom.style
				background: 'white'
				padding: '10px'
			Dom.h2 "Nieuwe Vergadering"
			Form.input
				name: 'naam'
				type: 'text'
				text: tr('Titel')
	
	else if p
		# Individuele vergadering
		vergadering = Db.shared.get("vergaderingen", p)
		if !vergadering
			Page.nav ''
		else
			Ui.list !->
				Dom.h2 "Actiepunten voor " + vergadering.naam
				Ui.item !->
					Dom.style color: Plugin.colors().highlight
					Dom.text tr(' + Nieuw Actiepunt')
					Dom.onTap !-> Page.nav 'addActiepunt/{p}'
					
				actiepunten = Db.shared.ref("vergaderingen", p, "actiepunten")
	
	else
		# Normal view
		Ui.list !->
			Dom.h2 "Vergaderingen"
			Ui.item !->
				Dom.style color: Plugin.colors().highlight
				Dom.text tr(' + Nieuwe vergadering')
				Dom.onTap !-> Page.nav 'newVergadering'
			
			vergaderingen = Db.shared.ref('vergaderingen')
			vergaderingen.iterate (vergadering) !->
				Ui.item !->
					Dom.div !->
						Dom.style
							marginLeft: '10px'
							Flex: true
						Dom.text vergadering.get('naam')
						
					Dom.div !->
						date = new Date(vergadering.get('datum'))
						Dom.text '' + date.getDate() + '/' + (date.getMonth()+1) + '/' + date.getFullYear()
					Dom.onTap !-> Page.nav vergadering.key()
			,(vergadering) -> (-vergadering.get('datum'))