Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Modal = require 'modal'
Obs = require 'obs'
Page = require 'page'
Plugin = require 'plugin'
Server = require 'server'
Ui = require 'ui'
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
						Page.back()
		
		
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
	
	else if p == 'v'
		# Individuele vergadering
		vID = Page.state.get(1)
		if vID
			vergadering = Db.shared.get("vergaderingen", vID)
			if !vergadering
				# Vergadering bestaat niet
				log 'fakeID'
				Page.nav ''
			else
				# Enkele bestaande vergadering
				p2 = Page.state.get(2)
				if p2 == 'newActiepunt'
					# Nieuw actiepunt toevoegen aan deze vergadering
					Form.setPageSubmit (values) !->
						naam = values.naam.trim()
						persoon = values.persoon
						if !naam
							Modal.show "U heeft geen titel ingevuld"
						else if !persoon
							Modal.show "U heeft geen persoon geselecteerd"
						else
							# Save new actiepunt
							Server.call 'newActiepunt', vID, naam, persoon, (res)->
								if res == "false"
									Modal.show 'Er iets mis gegaan, probeer het later nog eens'
								else
									Page.back()
						
					# Formulier
					Dom.div !->
						Dom.style
							background: 'white'
							padding: '10px'
						Dom.h2 "Nieuw Actiepunt"
						Form.input
							name: 'naam'
							type: 'text'
							text: tr('Titel')
						
						Form.sep()
						
						selectMember
							name: 'persoon'
							title: tr("Door wie?")
						
						
						
						
				else if p2 == 'a'
					# Enkel actiepunt van deze vergadering
				else
					# Vergadering overzicht
					Ui.list !->
						Dom.h2 "Actiepunten voor " + vergadering.naam
							
						actiepunten = Db.shared.ref("vergaderingen", vID, "actiepunten")
						if !actiepunten
							Ui.item !->
								Dom.div !->
									Dom.style
										fontStyle: 'italic'
									Dom.text 'Er zijn nog geen actiepunten voor deze vergadering'
						else
							actiepunten.iterate (actiepunt) !->
								Ui.item !->
									if (0|actiepunt.get('persoon')) == Plugin.userId()
										Dom.style fontWeight: 'bold'
									
									Ui.avatar Plugin.userAvatar(actiepunt.get('persoon'))
									
									Dom.div !->
										Dom.style
											marginLeft: '10px'
											Flex: true
										Dom.text actiepunt.get('naam')
									
									Dom.div !->
										Dom.img !->
											Dom.prop src: Plugin.resourceUri('status_' + actiepunt.get('status') + '.jpg')
											Dom.style
												height: '25px'
									
									if (0|actiepunt.get('persoon')) == Plugin.userId()
										Dom.onTap !->
											Server.call 'updateActiepunt', vID, actiepunt.key(), (res)->
												if res == "false"
													Modal.show 'Er iets mis gegaan, probeer het later nog eens'
													
						
					Page.setFooter
						label: tr('Actiepunt Toevoegen')
						action: !-> Page.nav ['v', vID, 'newActiepunt']
		else
			# Geen vergadering ID meegegeven
			log 'noID'
			Page.nav ''
	else
		# Normal view
		Ui.list !->
			Dom.h2 "Vergaderingen"
			
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
					Dom.onTap !-> Page.nav ['v', vergadering.key()]
			,(vergadering) -> (-vergadering.key())
			
			Page.setFooter
				label: tr('Vergadering Toevoegen')
				action: !-> Page.nav 'newVergadering'


# input that handles selection of a member
# Source: https://github.com/Happening/Chess/blob/master/client.coffee#L204
selectMember = (opts) !->
	opts ||= {}
	[handleChange, initValue] = Form.makeInput opts, (v) -> 0|v

	value = Obs.create(initValue)
	Form.box !->
		Dom.style fontSize: '125%', paddingRight: '56px'
		Dom.text opts.title||tr("Selected member")
		v = value.get()
		Dom.div !->
			Dom.style color: (if v then 'inherit' else '#aaa')
			Dom.text (if v then Plugin.userName(v) else tr("Nobody"))
		if v
			Ui.avatar Plugin.userAvatar(v), !->
				Dom.style position: 'absolute', right: '6px', top: '50%', marginTop: '-20px'

		Dom.onTap !->
			Modal.show opts.selectTitle||tr("Select member"), !->
				Dom.style width: '80%'
				Dom.div !->
					Dom.style
						maxHeight: '40%'
						overflow: 'auto'
						_overflowScrolling: 'touch'
						backgroundColor: '#eee'
						margin: '-12px'

					Plugin.users.iterate (user) !->
						Ui.item !->
							Ui.avatar user.get('avatar')
							Dom.text user.get('name')

							if +user.key() is +value.get()
								Dom.style fontWeight: 'bold'

								Dom.div !->
									Dom.style
										Flex: 1
										padding: '0 10px'
										textAlign: 'right'
										fontSize: '150%'
										color: Plugin.colors().highlight
									Dom.text "✓"

							Dom.onTap !->
								handleChange user.key()
								value.set user.key()
								Modal.remove()
			, (choice) !->
				log 'choice', choice
				if choice is 'clear'
					handleChange ''
					value.set ''
			, ['cancel', tr("Cancel"), 'clear', tr("Clear")]