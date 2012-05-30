class Show extends Spine.Controller
	# Set the HTML class
	className: 'show'

	events:
		'click .btn-hover.lookit': 'lookit'
		'click .btn-hover.open':   'open'
		'click .btn-hover.queue':  'enqueue'
		'click .btn-hover.remove': 'remove'

	constructor: ->
		super

		# Bind the change() callback
		# to the *active* event
		@active @change

	render: ->
		# Render a template, replacing the 
		# controller's HTML
		@html require('views/galleries/show')(Gallery.all())

	change: (params) =>
		@item = Gallery.find(params.id)
		@render()

	lookit: (e) ->
		e.preventDefault()

	open: (e) ->

	enqueue: (e) ->

	remove: (e) ->

	edit: ->
		# Navigate to the 'edit' view whenever
		# the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')

class App.Galleries extends Spine.Controller
	# elements:
	#   '.items': items
	# 
	# events:
	#   'click .item': 'itemClick'

	constructor: ->
		super
		# ...