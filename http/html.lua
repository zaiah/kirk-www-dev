------------------------------------------------------
-- html.lua 
--
-- Module allowing HTML tag wrapping functionality.
-- Without this module, a potential user will have
-- to use either:
-- * a templating system
-- * or write tags by hand. 
--
-- This module attempts to use Lua's power to create
-- tools that will make it easier to merge the 
-- abilities of the HTML spec and datastore activity.
------------------------------------------------------

------------------------------------------------------
-- global_modifiers {} 
--
-- Table of HTML4/5 modifiers used with each tag. 
------------------------------------------------------
local global_modifiers = { 
	"accesskey",
	"class", 
	"contenteditable",
	"contextmenu",
	"dir",
	"draggable",
	"dropzone",
	"hidden",
	"id", 
	"inert", 
	"itemid", 
	"itemprop", 
	"itemref", 
	"itemscope", 
	"itemtype", 
	"lang", 
	"spellcheck",
	"style",
	"tabindex",
	"title",
	"translate",
}

------------------------------------------------------
-- event_attr {} 
--
-- Table of HTML4/5 events that should work with all
-- tags. 
------------------------------------------------------
local event_attr = {
	"onblur",
	"onchange",
	"oncontextmenu",
	"onfocus",
	"onformchange",
	"onforminput",
	"oninput",
	"oninvalid",
	"onreset",
	"onselect",
	"onsubmit",
	"onkeydown",
	"onkeypress",
	"onkeyup",
	"onclick",
	"ondblclick",
	"ondrag",
	"ondragend",
	"ondragenter",
	"ondragleave",
	"ondragover",
	"ondragstart",
	"ondrop",
	"onmousedown",
	"onmousemove",
	"onmouseout",
	"onmouseover",
	"onmouseup",
	"onmousewheel",
	"onscroll",
	"onabort",
	"oncanplay",
	"oncanplaythrough",
	"ondurationchange",
	"onemptied",
	"onended",
	"onerror",
	"onloadeddata",
	"onloadedmetadata",
	"onloadstart",
	"onpause",
	"onplay",
	"onplaying",
	"onprogress",
	"onratechange",
	"onreadystatechange",
	"onseeked",
	"onseeking",
	"onstalled",
	"onsuspend",
	"ontimeupdate",
	"onvolumechange",
	"onwaiting",
}

------------------------------------------------------
-- body_event_attr {} 
--
-- Table of HTML4/5 attributes that can be used to 
-- modify an HTML body.
------------------------------------------------------
local body_event_attr = {
	"onafterprint",
	"onbeforeprint",
	"onbeforeonload",
	"onblur",
	"onerror",
	"onfocus",
	"onhaschange",
	"onload",
	"onmessage",
	"onoffline",
	"ononline",
	"onpagehide",
	"onpageshow",
	"onpopstate",
	"onredo",
	"onresize",
	"onstorage",
	"onundo",
	"onunload",
}


------------------------------------------------------
-- strict_tags {}
--
-- List of modifiers and their respective HTML4/5
-- tags. 
--
-- The list is long, so please check out:
-- http://w3schools.com for additional information
-- about each tag and what its available modifiers
-- do.  
------------------------------------------------------
local strict_tags = {
a = { 
	"download",
	"href",
	"hreflang",
	"rel",
	"target",
	"type" },
abbr = { 
	"download",
	"href",
	"hreflang",
	"rel",
	"style",
	"target",
	"type" },
acronym   = { },
address = { },
applet = { },
area = { 
	"alt",
	"coords",
	"shape",
	"href",
	"target",
	"download",
	"rel",
	"hreflang",
	"type" },
article = {  },
aside = { },
audio = { 
	"src",
	"crossorigin",
	"preload",
	"autoplay",
	"mediagroup",
	"loop",
	"muted",
	"controls"},
b = { },
base = {
	"href",
	"target" },
basefont = { },
bdi = { },
bdo = { },
big = { },
blockquote = {
	"cite" },
body = {
	"onload",
	"onafterprint",
	"onbeforeprint",
	"onbeforeunload",
	"onfullscreenchange",
	"onfullscreenerror",
	"onhashchange",
	"onmessage",
	"onoffline",
	"ononline",
	"onpagehide",
	"onpageshow",
	"onpopstate",
	"onresize",
	"onstorage",
	"onunload" },
br = { },
button = {
	"autofocus",
	"disabled",
	"form",
	"formaction",
	"formenctype",
	"formmethod",
	"formnovalidate",
	"formtarget",
	"name",
	"type",
	"value",
	"menu" },
canvas = {
	"width",
	"height" },
caption = { },
center = { },
cite = { },
code = { },
col = {
	"span" },
colgroup = {
	"span" },
comment = { },
data = {
	"value" },
datalist = { },
dd = { },
del = {
	"cite",
	"datetime" },
details = {
	"open" },
dfn = { },
dialog = {
	"open" },
div = { },
dl = { },
dt = { },
em = { },
embed = {
	"src",
	"type",
	"width",
	"height" },
fieldset = {
	"disabled",
	"form",
	"name" },
figcaption = { },
font = { },
footer = { },
form = {
	"accept_charset",
	"action",
	"enctype",
	"method",
	"name",
	"novalidate",
	"target" },
frame = { },
frameset = { },
h1 = { },
h2 = { },
h3 = { },
h4 = { },
h5 = { },
h6 = { },
head = { },
hr = { },
html = {
	"manifest" },
i = { },
iframe = {
	"src",
	"srcdoc",
	"name",
	"sandbox",
	"seamless",
	"allowfullscreen",
	"width",
	"height" },
img = {
	"alt",
	"src",
	"crossorigin",
	"usemap",
	"ismap",
	"width",
	"height" },
input = {
	"accept",
	"alt",
	"autocomplete",
	"autofocus",
	"checked",
	"dirname",
	"disabled",
	"form",
	"formaction",
	"formenctype",
	"formmethod",
	"formnovalidate",
	"formtarget",
	"height",
	"inputmode",
	"list",
	"max",
	"maxlength",
	"min",
	"multiple",
	"name",
	"pattern",
	"placeholder",
	"readonly",
	"required",
	"size",
	"src",
	"step",
	"type",
	"value",
	"width"},
ins = { 
	"cite",
	"datetime" },
isindex = { },
kbd = { },
keygen = { 
	"autofocus",
	"challenge",
	"disabled",
	"form",
	"keytype",
	"name" },
label = { 
	"for",
	"form" },
legend = { },
li = {
	"value" },
link = { 
	"href",
	"crossorigin",
	"rel",
	"media",
	"hreflang",
	"type",
	"sizes" },
main = { },
map = {
	"name" },
mark = { },
menu = {
	"type",
	"label" },
menulist = { },
menuitem = {
	"type",
	"label",
	"icon",
	"disabled",
	"checked",
	"radiogroup",
	"commands" },
meta = {
	"http_equiv",
	"name",
	"content",
	"charset" },
meter = {
	"value",
	"min",
	"max",
	"low",
	"high",
	"optimum" },
nav = { },
noframes = { },
noscript = { },
object = {
	"data",
	"type",
	"typemustmatch",
	"name",
	"usemap",
	"form",
	"width",
	"height" },
ol = {
	"reversed",
	"start",
	"type" },
optgroup = {
	"disabled",
	"label" },
option = {
	"disabled",
	"label",
	"selected",
	"value" },
output = {
	"for",
	"form",
	"name" },
p = { },
param = {
	"name",
	"value" },
pre = { },
progress = {
	"value",
	"max" },
q = {
	"cite" },
rp = { },
rt = { },
ruby = { },
s = { },
samp = { },
script = {
	"src",
	"type",
	"charset",
	"async",
	"defer",
	"crossorigin" },
section = { },
select = {
	"autofocus",
	"disabled",
	"form",
	"mulitple",
	"name",
	"required",
	"size" },
small = { },
source = {
	"src",
	"type",
	"media" },
span = { },
strike = { },
strong = { },
style = {
	"media",
	"type",
	"scoped" },
sub = { },
summary = { },
sup = { },
table = {
	"border",
	"sortable" },
tbody = { },
td = {
	"colspan",
	"rowspan",
	"headers" },
textarea = {
	"autocomplete",
	"autofocus",
	"cols",
	"dirname",
	"disabled",
	"form",
	"inputmode",
	"maxlength",
	"name",
	"placeholder",
	"readonly",
	"required",
	"rows" ,
	"value",
	"wrap" },
tfoot = { },
th = {
	"colspan",
	"rowspan",
	"headers",
	"scope",
	"abbr",
	"sorted" },
thead = { },
time = {
	"datetime" },
title = { },
tr = { },
track = {
	"kind",
	"src",
	"srclang",
	"label",
	"default" },
tt = { },
u = { },
ul = { },
var = { },
video = {  
	"src",
	"crossorigin",
	"poster",
	"preload",
	"autoplay",
	"mediagroup",
	"loop",
	"muted",
	"controls",
	"width",
	"height" },
wbr = { }
}


------------------------------------------------------
-- preferred_modifier {}
--
-- Holds a table of preferred modifiers.  When
-- supplying tables with alphanumeric indexes, this
-- module will automatically assign an id with the 
-- value of the index.
--
-- E.g.
-- html.div( { yukon = "Visit Now!" } ) results in:
-- <div id="yukon">Visit now!</div>
------------------------------------------------------
local preferred_modifier = {}
for k,__ in pairs(strict_tags)
do
	preferred_modifier[k] = 'id="%s"'
end
preferred_modifier["option"] = 'value="%s"'


------------------------------------------------------
-- pseudo do_tags() 
--
-- This function is assigned via a table to every tag. 
-- One may call html[tag]( x, y ) where [tag] is an 
-- HTML markup tag, and [x] and [y] are either strings, 
-- numbers or tables. 
--
-- Please refer to the documentation for the function
-- html listed below.
--
-- *string
------------------------------------------------------
local tag_wrap = {}
local tag_mods = {}
for k,v in pairs(strict_tags)
do
	tag_wrap[k] = function ( a1, a2, to_stdout ) 
		return (function ( e, f, g )
			------------------------------------------------------
			-- Get all HTML 4/5 "modifiers" that a tag supports.
			------------------------------------------------------
			tag_mods[k] = {}
			local strback
			for _,tablv in ipairs({global_modifiers,v,event_attr}) 
			do
				for _,vv in ipairs(tablv) 
				do 	
					table.insert(tag_mods[k],vv) 
				end 
			end

			------------------------------------------------------
			-- Encapsulate strings within "'s
			------------------------------------------------------
			local function quote_string(t)
				for ind,val in ipairs(t) do
					local str = string.chop(val,'=')	
					t[ind] = string.format('%s="%s"',str.key,str.value)
				end
				return t
			end

			------------------------------------------------------
			-- Encapsulate strings within "'s
			------------------------------------------------------
			local types = arg( e, f )
			local prmod = preferred_modifier[k]

			if types.table then
				local tt = {}
				if is.ni(e) then
					for _,v in ipairs(e) do 
						table.insert(tt, 
							string.format("<%s>%s</%s>",k,tostring(v),k))
					end
				else
					for kk,v in pairs(e) do 
						table.insert(tt, string.format('<%s %s>%s</%s>',
							k,string.format(prmod,kk),tostring(v),k))
					end
				end
				strback = table.concat(tt,"\n")

			elseif types.string 
			 or types.number then
				strback = string.format("<%s>%s</%s>\n",k,tostring(e),k)

			elseif types.strings 
			 or types.string_and_number
			then	
				strback = string.format(
					'<%s class="%s">%s</%s>\n',k,tostring(e),tostring(f),k)

			elseif types.string_and_table then	
				local tt = {}
				if is.ni(f) then
					for _,v in ipairs(f) do 
						table.insert(tt, 
							string.format(
							"<%s class=%s>%s</%s>\n",
							k,tostring(e),tostring(v),k))
					end
				else
					for y,v in pairs(f) do 
						table.insert( tt, 
							string.format(
							"<%s %s>%s</%s>\n",k,string.format(prmod,y),tostring(v),k))
					end
				end
				strback = table.concat(tt,"\n")

			elseif types.table_and_string 
			 or types.table_and_number then	
				local str
				if is.ni(e) then 
					e = quote_string(e)
					strback = string.format("<%s %s>%s</%s>",
						k,table.concat(e," "),tostring(f) or "",k)
				else
					str = table.concat(
						table.append_with_delim(tag_mods[k], e, nil, true )," ")
					strback = string.format("<%s %s>%s</%s>",
						k, str, tostring(f) or "",k)
				end
				
			elseif types.tables 
			then	
				local str
				local tt = {}

				if is.ni(e) and is.ni(f) 
				then
					-- Do some string encapsulation. 
					e = quote_string(e)

					for _,val in ipairs(f) do
						table.insert(tt,
							string.format("<%s %s>%s</%s>",
								k,table.concat( e,' '),tostring(val) or "",k))
					end

				elseif is.ni(e) and not is.ni(f) 
				then
					e = quote_string(e)

					for kk,val in pairs(f) do 
						table.insert(tt,
							string.format("<%s %s %s>%s</%s>",
								k, string.format(prmod,kk), 
								table.concat(e," "), tostring(val) or "",k))
					end

				elseif not is.ni(e) and is.ni(f) 
				then
					for __,val in ipairs(f) do 
						str = table.concat(
							table.append_with_delim(tag_mods[k], e, nil, true )," ")
						table.insert(tt,
							string.format('<%s %s>%s</%s>',
								k, str, tostring(val) or "",k))
					end
				else
					for kk,val in pairs(f) do 
						str = table.concat(
							table.append_with_delim(tag_mods[k], e, nil, true )," ")
						table.insert(tt,
							string.format('<%s %s %s>%s</%s>',
								k, string.format(prmod,kk), str, tostring(val) or "",k))
					end
				end
				strback = table.concat(tt,"\n")

			else 
--[[
				response.abort({500},"One of the formats provided to " ..
					"<i>function html." .. k .. "( )" ..
					"</i> is not of type table or string.")
--]]
-- P ( table.as_string( types ) )
			end

			-- Returning HTML and stuff.
			if g then P( tostring(strback)  )
			else return tostring(strback) end
		end)( a1, a2, to_stdout )
	end
end

------------------------------------------------------
-- pseudo metas_and_sugar
--
-- Syntactic sugar to facilitate common
-- transformations.
------------------------------------------------------
tag_wrap["id"] = function ( e1, e2, ts ) 
	if type(e1) == 'string' then
		return tag_wrap["div"]({["id"] = e1},e2,ts)
	else return tag_wrap["div"](e1,e2,ts) end end


tag_wrap["class"] = function ( e1, e2, ts ) 
	if type(e1) == 'string' then
		return tag_wrap["div"]({["class"] = e1},e2,ts)
	else return tag_wrap["div"](e1,e2,ts) end end


tag_wrap["href"] = function ( e1, e2, ts ) 
	if type(e1) == 'string' then
		return tag_wrap["a"]({["href"] = e1},e2,ts)
	else return tag_wrap["a"](e1,e2,ts) end end


------------------------------------------------------
-- {} Public methods  
--
-- These are in addition to the tags supported by
-- the HTML 4.01 and HTML5 specification.
------------------------------------------------------

------------------------------------------------------
-- .open( t ) 
--
-- Will create the most common items within an HTML
-- document's <head> tag.  This is mostly syntactic
-- sugar as virtually all HTML4/5 tags are supported
-- in some way.
--
-- Possible arguments are as follows:
--
-- css [string, table] 
-- 	When css is a [string], kirk will search in 
-- 	$DOCROOT/public/styles for a matching stylesheet. 
-- 	When css is a [table], kirk will find all matching 
-- 	stylesheet filenames it can from the table.  Names 
-- 	that are not found are not ignored, but a 404 will 
-- 	be generated by the server regardless.
--
-- doctype [string] 
-- 	A string defining the doctype to use when rendering 
-- 	a page.
--
-- favicon [string] 
-- 	[string] containing the filename and server path of 
-- 	a favicon.  
-- 
-- meta[string, table] 
-- 	...
--
-- jscript[string, table]
-- 	[string] containing the relative path to a 
-- 	javascript file.
-- 	[table] contains a list of strings to javascript
-- 	files.
--
-- link[table]
-- 	[table] containing the tags that specify the 
-- 	relationship between our page and the linked
-- 	document. Requires keys rel and href to work
-- 	properly.
--
-- raw[string, table]
-- 	[string] or [table] containing raw text that
-- 	one would like to place within the header.  This
-- 	is probably most appropriate for vendor specific
-- 	tags, doctypes or directives that must be stored
-- 	within the head tag.
--
-- title[string]
-- 	[string] defining the title of the document.
-- 	Overrides whatever is written in 
-- 	data/definitions.lua (the variable pg.title).
--
-- script[string, table]
-- 	[string] or [table] defining the location of a
-- 	script within $DOCROOT.  This is especially 
-- 	useful if whatever script we're asking for is
-- 	NOT written in Javascript.
--
-- *nil
------------------------------------------------------
tag_wrap["open"] = function(t)
	local this,decl = {},{}

	if t then
		this = table.retrieve({
			-- HTML4/5 Spec
			"doctype",	-- Do doctype negotiation.
			"css", 		-- Include stylesheets in <head>.
			"favicon", 	-- Include a particular favicon in <head>, overriding [pg].
			"meta", 		-- Meta tag encapsulations in <head>.
			"link", 		-- Include other code via <link rel= in <head> tags.
			"title",		-- Drop a <title> tag between <head> tags.
			"script",	-- Drop client scripts within the <head> tags.

			-- Kirk Extensions
			"jscript",	-- Include javascript files within $DOCROOT/js
			"xmlhttp",	-- Turn on Kirk's XMLHttpRequest handling library.
			"raw", 		-- Drop raw text within the <head> tag.
							-- (It's assumed you'll be handling your own markup when 
							-- using this key.)
		},t)
	end

	-- Doctype madness.
	if this.doctype then
	else 
		table.insert(decl, "<!doctype html>")
	end

	-- Start the head tag.
	table.insert(decl,"<head>")

	-- Include any CSS.  
	-- No css should be output if pg.default.css is empty. 
	cssstr = '<link rel="stylesheet" href="/styles/%s.css" style="text/css">'
	if this.css or pg.default.css 
	then
		local cssp = this.css or pg.default.css
		if type(cssp) == 'table' 
		then
			for _,inc in ipairs(cssp) do 
				table.insert(decl,string.format(cssstr, inc)) 
			end
		elseif type(cssp) == 'string' then
			table.insert(decl,string.format(cssstr, cssp)) 
		end
	end

	-- Define a favicon.
	if type(this.favicon) == 'string' 
	 or type(pg.default.favicon) == 'string' then
		local favi = this.favicon or pg.default.favicon
		faviconstr = '<link rel="icon" type="image/png" href="%s">'
		table.insert(decl,string.format(faviconstr, favi))
	end	

	-- Define a sitewide title.
	if type(this.title) == 'string' 
	 or type(pg.default.title) == 'string' then
		local title = this.title or pg.default.title 
		table.insert(decl,tag_wrap.title(title))
	end

	-- Placeholder string for Javascript.
	local s = '<script src="%s.js"></script>'

	-- kirk-js
	if pg.xmlhttp then
		for _,val in ipairs({
		   "/js/kirk-js/debug",
		   "/js/kirk-js/autobind",
		   "/js/kirk-js/variables",
		   "/js/kirk-js/xmlhttp",
		   "/js/kirk-js/send_test_req",
		-- "/js/kirk-js/get",
		   "/js/kirk-js/json",
		-- "/js/kirk-js/kirk",
		-- "/js/kirk-js/os",
		   "/js/kirk-js/send_get_req",		-- Amalgamate into requestor.js
		   "/js/kirk-js/send_multipart_post_req",
		   "/js/kirk-js/send_www-url-form-enc-post_req",
		-- "/js/kirk-js/testjs",
		   "/js/kirk-js/init",
		})
		do
			table.insert(decl,string.format(s,val))
		end	
	end

	-- Include any script tags.
	if type(this.script) == 'string' 
	then
		local s = '<script src="%s.js"></script>'
		table.insert(decl,string.format(s,this.script))
	elseif type(this.script) == 'table' 
	then
		for _,val in ipairs(this.script) do
			table.insert(decl,string.format(s,val))
		end	
	end

	-- Include any meta tags.
	if type(this.meta) == 'string' 
	 or type(pg.default.meta) == 'string' 
	then

	elseif type(this.meta) == 'table' 
	 or type(pg.default.meta) == 'table' 
	then

	end

	-- Just drop raw stuff.
	if type(this.raw) == 'string' then
		table.insert(decl,this.raw)
	elseif type(this.raw) == 'table' then
		for _,val in ipairs(this.raw) do
			table.insert(decl,val)
		end
	end

	-- Include any script tags.
	if type(this.jscript) == 'string' 
	then
		local s = '<script type="text/javascript" src="%s.js"></script>'
		table.insert(decl,string.format(s,this.jscript))
	elseif type(this.jscript) == 'table' 
	then
		local s = '<script type="text/javascript" src="%s.js"></script>'
		for _,val in ipairs(this.jscript) do
			table.insert(decl,string.format(s, val))
		end	
	end

	-- Grab additional links and includes.
	if this.link then
	end

	-- Activate xmlhttp object.
	-- Automatically includes kirk.js:
	-- refer to js/kirk.js for more on what exactly is going on.
	if this.xmlhttp then
		local s = '<script type="text/javascript" src="/js/kirk.js"></script>'
		table.insert(decl,s)
	end

	------------------------------------------------------
	-- Add to STDOUT
	------------------------------------------------------
	table.insert(decl,"</head>")
	P(table.concat(decl, "\n"))
end

------------------------------------------------------
-- .script() 
--
-- ...
--
-- *string
------------------------------------------------------
tag_wrap["script"] = function (t)
	local term = '<script type="text/javascript" src="/js/%s.js"></script>'
	if t 
	 and type(t) == 'table'
	then
		local uu = {}
		for key,val in ipairs(t)
		do
			uu[key] = string.format(term,val)
		end
		P(table.concat(uu,"\n"))
	elseif t
	 and type(t) == 'string'
	then
		P(string.format(term,t))
	end
end


return {
	------------------------------------------------------
	-- .html(x, y)
	--
	-- HTML tag wrapping functions.
	--
	-- If [x] is an alphanumerically indexed table (e.g.
	-- { lyfe = "jennings" }), then depending on the 
	-- preferred modifier coded in, [tag]'s markup will
	-- be output with a class, id, or value containing
	-- the string "lyfe".  The string "jennings" would
	-- be encapsulated by [tag]. 
	--
	-- Example:
	-- html.div( { yukon = "Visit Now!" } ) results in:
	-- <div id="yukon">Visit now!</div>
	--
	-- Here is a short list of the rest of the different 
	-- formats.
	-- 
	-- When x = [string, number]
	-- calls to html.div(x) will yield:
	-- 	<div>x</div>
	--
	-- When x = string; y = table containing 3 values
	-- calls to: html.div(x, y} will yield
	-- 	<div class=x> y[1] </div>
	-- 	<div class=x> y[2] </div>
	-- 	<div class=x> y[3] </div>
	-- x cannot be a number in this case. 
	--
	-- When x = string; y = [string, number]
	-- calls to: html.div(x,y) will yield
	-- 	<div class=x>y</div>
	-- x cannot be a number in this case. 
	--
	-- The following holds true for tables supplied as 
	-- the first argument to an html.lua function 
	-- corresponding to an HTML tag:
	--
	-- When x = table it must contain either 
	-- 	an alphanumerically indexed table with HTML4/5 
	-- 	tags as indexes, e.g.: { id = "joe", class = "john" }
	-- or
	-- 	a numerically indexed table composed of HTML4/5 tags
	-- 	joined to their assumed values with an equal sign, 
	-- 	e.g: { "id=willis", "class=jonas" } 
	--
	-- When x = table and y = [string, number] 
	-- calls to: html.div( x, y ) will yield either
	--    <div x1 x2>y</div>
	--    or
	--    <div x1.name="x1.value" x2.name="x2.value">y</div>
	--
	-- When x = table and y = table
	-- calls to: html.div( x, y ) will yield either
	-- 	<div x1 x2>y1</div>
	-- 	<div x1 x2>y2</div>
	-- 	<div x1 x2>y3</div>
	-- 	
	-- 	or
	--
	--    <div x1.name="x1.value" x2.name="x2.value">y1</div>
	--    <div x1.name="x1.value" x2.name="x2.value">y2</div>
	--    <div x1.name="x1.value" x2.name="x2.value">y3</div>
	--
	-- *table
	------------------------------------------------------
	html = tag_wrap,

	------------------------------------------------------
	-- htags( e ) 
	--
	-- Function to return the available class modifiers
	-- of a tag [e] via table.
	--
	-- *table
	------------------------------------------------------
	htags = function ( e )
		if type(e) == 'string' 
		then
			for __,TAG in ipairs( 
				table.union(global_modifiers, event_attr) )
			do
				table.insert( strict_tags[e], TAG )
			end
		else
			response.abort({500},[[Argument 1 supplied to htags must
				be a string.]])
		end	
		return strict_tags[e]
	end, 

	jstags = function ( e )

	end,
}
