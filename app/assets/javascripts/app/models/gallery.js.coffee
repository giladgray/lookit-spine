class App.Gallery extends Spine.Model
	@configure 'Gallery', 'title', 'type', 'pageUrl', 'thumbUrl'
	#@extend Spine.Model.Ajax

	@belongsTo 'page', 'App.Page'

	@filter: (query, types) ->
		console.log "filter stops by #{query} and #{types}"
		return @all() unless query or types
		types = [] unless types
		query = query.toLowerCase()
		@select (item) ->
			#console.log "type: #{item.type} - #{item.type in types}"
			(item.type in types) and
			(item.pageUrl?.toLowerCase().indexOf(query) isnt -1 or
				 item.title?.toLowerCase().indexOf(query) isnt -1)
