# Spine = require('spine')
# $     = Spine.$

class App.Gallery extends Spine.Model
	@configure 'Gallery', 'title', 'type', 'pageUrl', 'thumbUrl'
	#@extend Spine.Model.Ajax

	@filter: (query) ->
		return @all() unless query
		query = query.toLowerCase()
		@select (item) ->
			item.pageUrl?.toLowerCase().indexOf(query) isnt -1 or
				item.title?.toLowerCase().indexOf(query) isnt -1

	@fromUrl: (url) ->
		safeUrl = if url.startsWith("http://") then url else "http://#{url}"
		console.log "Loading URL " + url
		# load the page, find all image links and process them
		$.get url, (response) ->
			for pic in $(response).find('a>img').parent()
				pic = $(pic)
				img = pic.find('img')
				App.Gallery.create
					title: img.attr('alt')
					type: discernType(pic.attr('href'))
					pageUrl: pic.attr 'href'		# urlMagic(pic.attr('href'), safeUrl)
					thumbUrl: img.attr 'src'		#urlMagic(img.attr('src'))
