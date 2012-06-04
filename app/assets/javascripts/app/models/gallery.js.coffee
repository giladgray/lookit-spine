class App.Gallery extends Spine.Model
	@configure 'Gallery', 'title', 'type', 'pageUrl', 'thumbUrl'
	#@extend Spine.Model.Ajax

	@belongsTo 'page', 'App.Page'

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.pageUrl?.toLowerCase().indexOf(query) isnt -1 or
				item.title?.toLowerCase().indexOf(query) isnt -1
