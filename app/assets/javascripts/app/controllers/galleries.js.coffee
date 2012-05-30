#List = require('spine/lib/list')

class App.Galleries extends Spine.Controller
	# Set the HTML class
	className: 'contents'

	elements:
		'.site-list': 'items'
		'#search':  'search'

	events:
		'keyup #filter': 'filter'
		#'click .btn-hover.lookit': 'lookit'
		#'click .btn-hover.open':   'open'
		#'click .btn-hover.queue':  'enqueue'
		#'click .btn-hover.remove': 'remove'

	constructor: ->
		super
		# render inital view
		@html require('views/search')()

		# setup a Spine List
		@list = new List
			el: @items
			template: require('views/galleries/gallery')
		
		@list.bind 'change', @change

		@active @filter
		# @active (params) ->
		# 	@list.change(Gallery.find(params.id))

	filter: ->
		@query = @search.val()
		@render()

	render: ->
		# Render a template, replacing the 
		# controller's HTML
		@list.render(Gallery.filter(@query))

	change: (params) =>
		console.log "Show#change called."
		console.log params
		#@item = Gallery.find(params.id)
		#@render()

	lookit: (e) ->
		e.preventDefault()

	open: (e) ->

	enqueue: (e) ->

	remove: (e) ->

	edit: ->
		# Navigate to the 'edit' view whenever
		# the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')