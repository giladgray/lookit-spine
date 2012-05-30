# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# filetypes that can be displayed in the carousel
window.displayTypes = 
	gallery: 
		pattern: /(\w+)\/?(\w\.html)?\??(.*)/
		show: (url) -> window.open "/?url=#{url}"
		icon: 'icon-th'
	image: 
		pattern: /\.(jpg|png|bmp|gif|jpeg)$/
		show: (url) -> showModal div('body', img(url))
		icon: 'icon-picture'
	video: 
		pattern: /\.(mpg|mov|mp4|flv)$/
		show: (url) -> showModal createVideo(url)
		icon: 'icon-film'
	embed: 
		pattern: /<embed/
		show: (url) ->
		icon: 'icon-file'
	none:
		pattern: /\.wmv$/
		show: (url) -> window.open url
		icon: 'icon-share'
# TODO: implement HTML5 video tags

# list of blacklist regexes that will reject a URL
window.blacklist = [] # [/(\/|\.)ads?(\/|\.)/]
window.blacklisted = (string) ->
	reject = false
	# check the string against each blacklist entry
	for item in blacklist
		if item.test(string)
			reject = true 
			console.log "'#{string}' rejected by blacklist"
			break
	reject

window.UrlRegex = ///
	https?://									# starts with http:// or https://
	([\w\d\.]+\.[\w\d]{2,3})	# 1. host name (something.com)
	([-_\w\d\./:]*)						# 2. relative part of the path (/w/1234/gallery/index.html)
	(?:\?([-=_\w\d&]+))?			# 3. query string, after the ?. surrounded by non-capturing optional group
///
# (/index\.[\w]{2-4})?)			# filename (index.htm|html|php)

# the best regex: https?\:\/\/(?<url>[\w\d\.]+\.[\w\d]{2,3})(?<path>[-_\w\d\.\/\:]*)(\?(?<query>[-=_\w\d\&]+))?
window.urlMagic = (plainUrl, siteUrl) ->
	# URL TYPES:
	#                 [    url    ]/[          page           ]?[      query     ]
	# gallery: http://www.blank.com/path/to/gallery/(page.html)(?query=parameters)
	# image: http://www.blank.com/path/to/image.type
	# video: http://www.blank.com/path/to/video.type
	# relative: /path/to/whatever  

	#return null if url is null or blacklisted(url)

	# search url string for valid URL with http:// prefix, GTFO if fail.
	# this ignores relative links and finds URLs hidden in query string.
	urlMatch = /(https?\:\/\/[-\w\d\.\/\:]*)\??/.exec plainUrl
	if urlMatch is null  # no match
		# make relative URL into whole URL
		siteUrl = siteUrl.substring(0, siteUrl.length - 1) if siteUrl.endsWith '/'
		plainUrl = '/' + plainUrl unless plainUrl.startsWith '/'
		url = siteUrl + plainUrl
	else  # we've got a match
		url = urlMatch[1]
	return if url is null
	url = url.replace(/(\"|')/g, "").replace(/\s/g, "+")
	console.log "#{plainUrl} ==> #{url}"
	url

window.discernType = (url) ->
	for type, value of displayTypes
		urlType = type if value.pattern.test(url)
	urlType

window.linkMagic = (url) ->
	# determine link type using type:regex hash
	urlType = "gallery"
	for type, value of displayTypes
		if value.pattern.test(url)
			urlType = type 
			icon = value.icon
	# return html link tag
	[link(url, "pic #{urlType}").attr("target", "_blank"),
	 span("type btn-hover horizontal", "<i class='#{icon}'></i>")]

handlePicClick = (pic) =>
	console.log "handling click for #{pic.attr("class")}: #{pic.attr('href')}"
	if $("#useHistory").hasClass("active")
		$("#history").append(pic.detach())
	for type, value of displayTypes
		if pic.hasClass(type) then value.show(pic.attr('href'))

processImageLink = (tag, siteUrl) ->
	[linktag, typetag] = linkMagic urlMagic($(tag).attr("href"), siteUrl)
	linktag.append img(urlMagic($(tag).find("img").attr("src"), siteUrl))

	# the X button (top-right) deletes this pic
	close = span("close btn-hover vertical", "&times;").hide().click (event) ->
		event.preventDefault()
		$(this).closest(".pic-container").remove()

	# the Q button (bottom) adds this pic to the queue
	queue = span("queue btn-hover horizontal", "+queue").hide().click (event) ->
		$("#queue").append $(this).closest(".pic-container").remove()

	# the OPEN button (top-left) opens this link in a new lookit window
	open = span("lookit btn-hover vertical", '<i class="icon-share"></i>').hide().click (event) ->
		url = $(this).closest(".pic-container").find("a").attr("href")
		console.log "launching link in new lookit: #{url}"
		window.open url #"/?url=#{encodeURIComponent(url)}"

	# create a new link tag so we can set our own attributes on it
	linktag.click (event) ->
		event.preventDefault()
		handlePicClick $(@)
	# make the pic-container tag, containing the link and all the controls we created above
	spantag = span "pic-container", linktag, typetag, close, queue, open
	# add some event listeners to the pic-container: click to send to history, hover to show buttons
	spantag.hover((-> $(this).children(".btn-hover").show()), (-> $(this).children(".btn-hover").hide()))
	spantag

window.loadImages = (url) ->
	document.title = url + " @ lookit"
	safeUrl = if url.startsWith("http://") then url else "http://#{url}"
	console.log "Loading URL " + url
	# load the page, find all image links and process them
	$.get "/show", url: safeUrl, (response) ->
		dest = createContents(url, safeUrl)
		$(".container").append dest
		dest.find(".site-list").append(processImageLink($(pic), safeUrl)) for pic in $(response).find("a>img").parent()
		#$(response).find("a>img").parent().each processImageLink
		$("input#url").val ""

contentIndex = 0
createContents = (name, url) ->
	id = "content#{contentIndex++}"
	# remove button deletes this row from the UI
	remove = btn("remove", icon("trash")).attr("title", "Remove this gallery").attr("data-remove", id).click ->
		$(this).parent().parent().parent().remove()
	# refresh button reloads images from the URL
	refresh = btn("refresh", icon("refresh")).attr("title", "Refresh this gallery").attr("data-refresh", name).click ->
		loadImages($(this).data("refresh"))
		# NOTE that refresh is accomplished by simply redoing the loadImages action
		remove.click()
	carousel = btn("", icon("play")).attr("title", "Slideshow it!").attr("data-list", id).click ->
		showModal createCarousel($("#" + $(this).data("list")))

	header = div "page-header", div("btn-group right", carousel, refresh, remove), tag("<h2>", '', link(url, '', name)) #.attr("target", "_blank"))
	div "row", header, div("site-list").attr("id", id)

createCarousel = (list) ->
	console.log "Creating carousel... " + list
	# construct the carousel HTML
	carousel = div "carousel slide", inner = div("carousel-inner"), link("#carousel", "left carousel-control btn-hover", "&lsaquo;").attr("data-slide", "prev"), link("#carousel", "right carousel-control btn-hover", "&rsaquo;").attr("data-slide", "next")
	carousel.attr("id", "carousel")

	# add items from the list to the carousel
	for pic in list.find("a")
		src = $(pic).attr("href")
		# only add item to carousel if it is a link to an acceptable filetype
		inner.append div("item", img(src)) if displayTypes.image.pattern.test(src)
	inner.find(":first-child").addClass("active")

	carousel

createVideo = (src, width=480, height=320) ->
	console.log "Creating video... #{src}"
	#$("<video>").attr("src", src).attr("controls", "controls")

	video = $("<div>").attr("id", "video").addClass("video")
	jwplayer('video').setup
		flashplayer: 'player.swf'
		file: src
		controlbar: 'bottom'
		width: width,
		height: height
	video

showModal = (contents) ->
	# show a modal dialog with the given contents
	div("modal", contents).attr("id", "modal").modal('show')

$(document).ready ->
	# click the lookit button to load images from the URL
	$("button#lookit").click (event) ->
		event.preventDefault()
		loadImages $("input#url").val()

	# clear button removes all pic-containers from data-clear element
	$("button.clear").on "click", (event) ->
		id = $(this).data("clear")
		console.log "clearing ##{id}"
		$("##{id}").children(".pic-container").remove()

	# open queue button launches each queued link in a new background window
	$("button#openQueue").click ->
		for pic in $("#queue").children(".pic-container")
			window.open $(pic).find("a").attr("href")
			$("#history").append $(pic).remove()
		self.focus()

	# enter key handler for text input
	$("input#url").keypress (event) ->
		$("button#lookit").click()  if event.which is 13

	# automatically load images if URL parameter is specified.
	# the text input will be preloaded with params[:url] if it exists.
	$("button#lookit").click() if $("input#url").val()

	$(window).resize (event) ->
		if window.innerWidth < 1000
			$(".sidebar").addClass("minimize")
		else
			$(".sidebar").removeClass("minimize")