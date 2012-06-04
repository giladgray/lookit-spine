class App.Page extends Spine.Model
	@configure 'Page', 'title', 'url'

	@hasMany 'galleries', 'App.Gallery'


	@fromUrl: (url, callback) ->
		safeUrl = if url.startsWith("http://") then url else "http://#{url}"
		console.log "Loading URL " + url
		# load the page, find all image links and process them
		$.get url, (response) ->
			window.rsp = $(response)
			page = App.Page.create
				title: rsp.find('title').text()
				url: url
			for pic in rsp.find('a>img').parent()
				pic = $(pic)
				img = pic.find('img')
				gal = App.Gallery.create
					title: img.attr('alt')
					type: discernType(pic.attr('href'))
					pageUrl: urlMagic(pic.attr('href'), safeUrl)
					thumbUrl: urlMagic(img.attr('src'), safeUrl)
				console.log "created pic #{gal.pageUrl}"
			callback page