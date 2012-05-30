String::startsWith = (prefix) ->
  @substring(0, prefix.length) is prefix

String::endsWith = (suffix) ->
  @indexOf(suffix, this.length - suffix.length) != -1

window.defaultValue = (value, defaultValue) ->
  if value? then value else defaultValue

# HTML GENERATORS (jQuery wrappers perfect for coffeescripting)
window.tag = (tagname, classes, body...) ->
  html = $(tagname).addClass(classes)
  html.append text for text in body
  html
window.div = (classes, body...) ->
  tag "<div>", classes, body...
window.span = (classes, body...) ->
  tag "<span>", classes, body...
window.btn = (classes, body...) ->
  tag "<button>", "btn #{classes}", body...
window.li = (classes, body...) ->
  tag "<li>", classes, body...
window.link = (href, classes, body...) ->
  tag("<a>", classes, body...).attr("href", href)
window.img = (src, classes, body...) ->
  tag("<img>", classes, body...).attr("src", src)
# a special helper for icons in Twitter Bootstrap
window.icon = (name, color) ->
  html = tag("<i>", "icon-#{name}")
  html.addClass("icon-#{color}") if color
  html