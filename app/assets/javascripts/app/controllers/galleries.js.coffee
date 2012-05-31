#List = require('spine/lib/list')

class App.Galleries extends Spine.Controller
	# Set the HTML class
	className: 'contents'

	elements:
		'.site-list': 'items'
		'#search': 'search'
		'#filter': 'filter'

	events:
		'keyup #filter': 'render'
		'submit form': 'loadPage'
		'click .pic': 'lookit'
		'click .open.btn-hover':  'open'
		'click .queue.btn-hover': 'enqueue'
		'click .close.btn-hover': 'delete'

	constructor: ->
		super
		# render inital view
		@html @view('search')()

		# setup a Spine List
		@list = new Spine.List
			el: @items
			template: @view('galleries/gallery')
		
		@list.bind 'change', @change

		@active @render
		# @active (params) ->
		# 	@list.change(Gallery.find(params.id))

	render: ->
		# Render a template, replacing the 
		# controller's HTML
		@query = @filter.val()
		galleries = App.Gallery.filter(@query)
		@list.render(galleries)

	change: (params) =>
		console.log "Show#change called."
		console.log params
		#@item = Gallery.find(params.id)
		@render()

	loadPage: (e) ->
		e.preventDefault()
		console.log "loading page #{@search.val()}"
		App.Gallery.fromUrl(@search.val(), () => @render())

	lookit: (e) ->
		e.preventDefault()
		console.log "lookit clicked"
		url = $(e.target).parent().attr('href')
		window.open url

	open: (e) ->
		console.log "open clicked"
		console.log $(e.currentTarget).siblings('.pic')
		console.log e

	enqueue: (e) ->
		console.log "queue clicked"
		console.log e

	delete: (e) ->
		console.log "close clicked"
		$(e.target).parent().remove()

	edit: ->
		# Navigate to the 'edit' view whenever
		# the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')