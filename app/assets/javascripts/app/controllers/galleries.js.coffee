#List = require('spine/lib/list')

class App.Galleries extends Spine.Controller
	# Set the HTML class
	className: 'contents'

	elements:
		'.page-header': 'header'
		'.site-list': 'items'
		'#search': 'search'
		'#filter': 'filter'

	events:
		'keyup #filter': 'render'
		'submit form': 'loadPage'
		'click .open.btn-hover':  'open'
		'click .queue.btn-hover': 'enqueue'
		'click .close.btn-hover': 'delete'
		'click .pic.image': 'carousel'
		'click .pic.video': 'player'
		'click .pic.gallery': 'lookit'

	constructor: ->
		super
		# render inital view
		@html @view('search')()

		# setup a Spine List
		@list = new Spine.List
			el: @items
			template: @view('galleries/list')
		
		@list.bind 'change', @change

		@active (params) ->
			console.log "activated with url=#{params.url}"
			App.Page.fromUrl(params.url, @change) if params.url

	render: ->
		@header.html @view('pages/header')(@page)
		@query = @filter.val()
		galleries = App.Gallery.filter(@query)
		@list.render(galleries)

	change: (page) =>
		console.log "Show#change called."
		@page = page
		@render()

	# loads a page when the user submits the lookit form
	loadPage: (e) ->
		e.preventDefault()
		console.log "loading page #{@search.val()}"
		App.Page.fromUrl(@search.val(), () => @render())

	# opens clicked pic in new lookit window
	lookit: (e) ->
		e.preventDefault()
		console.log "lookit clicked"
		url = $(e.target).parent().attr('href')
		window.open "/#/oo/#{url}"

	# opens clicked pic url in new window
	open: (e) ->
		console.log "open clicked"
		console.log $(e.currentTarget).siblings('.pic')
		console.log e

	# adds clicked pic to queue
	enqueue: (e) ->
		console.log "queue clicked"
		console.log e

	# removes clicked pic (sends to history if enabled)
	delete: (e) ->
		console.log "close clicked"
		$(e.target).parent().remove()

	edit: ->
		# Navigate to the 'edit' view whenever
		# the edit link is clicked
		@navigate('/contacts', @item.id, 'edit')