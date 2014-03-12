#!/usr/bin/lua
------------------------------------------------------
-- index.lua
--
-- Main handler for CGI/FCGI scripts.
------------------------------------------------------=
VERSION = "Pagan 1.1"
LOCALE  = "EN:us"
DATE	= os.date('*t',os.time())
NOW     = function () return os.date('*t', os.time()) end
RECVD	= os.time()
TIME 	= os.time()
-- L	= require("i18n.locale")
pg = dofile("../data/definitions.lua") 

------------------------------------------------------
-- Load functionality.  
------------------------------------------------------
interpret = require("file.interpret")		-- Wrap loading files.
is        = require("extension.tests").is -- Useful tests.
are       = require("extension.tests").are -- More useful tests.
table     = require("extension.tables")	-- Table extensions. 
string    = require("extension.strings") 	-- String extensions. 
date      = require("extension.date")		-- Dates
uuid      = require("extension.uuid")		-- Random ID Generation
shuffle   = require("extension.shuffler")	-- Shuffle keys from a table.
arg       = require("extension.arg")		-- Repetitive argument processing.
-- co     = require("extension.coroutine")-- Send functions through coroutines.

response  = require("http.response")      -- Response library
-- request = require("http.request")      -- Request library.
html      = require("http.html").html		-- HTML encapsulation.
htags     = require("http.html").htags		-- List of available HTML tags
_         = html							-- Will have to replace b/c this overloads.
cookie    = require("http.cookie")			-- Cookies
scodes    = require("http.status")			-- Common status codes.
E         = require("http.eval4")			-- Routing and resources.

D         = require("ds.db")					-- ORM interface
F         = require("file.file") 			-- File interaction
add       = require("file.add")				-- Preload common files.
-- S      = require("http.sockets")			-- Send data over sockets.
C         = require("ds.content")			-- Get something from a database.
as        = require("ds.serialization")	-- Serialization formats.
render    = require("template/render")		-- Template rendering.
die       = require("error")					-- Error handling.
ctypes    = require("http.content-types") -- Possible Content-Types
console   = require("debugger")           -- Console for debugging.

------------------------------------------------------
-- Check here if pg.path/index.lua actually exists.
------------------------------------------------------
-- ...

------------------------------------------------------
-- There must be something else that will help you
-- create this.
------------------------------------------------------
pg.dbsch	= D.generate_schema(pg.dbname) 

------------------------------------------------------
-- Finally add the globals needed to make this useful.
------------------------------------------------------
data = { url = {}, resource = {} }
HEADERS = { USER = {} }

------------------------------------------------------
-- crbody(queue,t) 
--
-- Append queue to t, to generate a message body for
-- stdout or stderr. 
-- 
-- Also discards strings when simply concatenating 
-- with a comma.  (i.e. P(k,y) does not work like 
-- print(k,y).
------------------------------------------------------
local function crbody(queue,t)
	local int = table.maxn(t) or 0

	-- Is [queue] a table?
	if type(queue) == 'table'			
	then
		if is.ni(queue) then
			t[int + 1] = table.concat(queue,"\n")
		else
			return
		end

	-- Check for either function or nil.
	elseif type(queue) == 'function' 
	 or type(queue) == 'nil' 			
	then
		t[int + 1] = tostring(queue)

	-- Is [queue] a string or a number?
	elseif type(queue) == 'string' 
	 or type(queue) == 'number'	-- String
	then
		t[int + 1] = queue 

	-- [queue] can't do any userdata.
	elseif type(queue) == 'userdata'
	then
		die.xerror({
			fn = "crbody",
			tn = type(queue),
			msg = "Cannot parse or interpret %t at %f."
		})
	end
end

------------------------------------------------------
-- STDIO, STDERR {}
--
-- Tables for emulating standard in and standard out. 
------------------------------------------------------
STDOUT, STDIN, STDERR = {}, {}, {}
P = function (queue) crbody(queue,STDOUT) end
B = function (queue) crbody(queue,STDERR) end

------------------------------------------------------
-- pseudo CLI 
--
-- Command line interface mode and options. 
-- WARNING: Will be ported later.
------------------------------------------------------
local args = {...}
if table.maxn(args) == 1 or table.maxn(args) > 1 then
	-- For interface testing...
	CGI = {
	--	GATEWAY_INTERFACE = ,
		PATH_INFO = "/",
		PATH_TRANSLATED = "/",
	--	QUERY_STRING = "/",
	--	REMOTE_ADDR,
		REQUEST_METHOD = "GET",
	--	SCRIPT_NAME = ,
	--	HTTP_COOKIE,
	--	HTTP_INTERNAL_SERVER_ERROR,
		SERVER_NAME = pg.domain,
		SERVER_PORT = pg.port or 80,
	--	SERVER_PROTOCOL = ,
		SERVER_SOFTWARE = "Kirk",
	--	REMOTE_HOST,
	--	REMOTE_IDENT,
	--	REMOTE_USER,
	}

	-- Tell the CGI handler that we've already filled this table.
	CGI_GEN = true 

	-- Move through the options in a clumsy manner.
	for x,n in ipairs(args) do
		if n == 'path' then CGI.PATH_INFO = args[x + 1]
		elseif n == 'cgi' then
			for x,y in pairs(CGI) do P(x .. '\t' .. y) end
		end 
	end
	
	-- Replacement for the above sometime in the future.
	--[[
	if pg.cli_on 
	then
		-- Evaluate any options.
		local oo = require("cli/options")( {...} )	
		if type(oo) == 'table' then
			require("cli/logic")( oo )
		end	
	end
	--]]
end

------------------------------------------------------
-- Disable a few things to keep from CGI hell.
------------------------------------------------------
-- assert   = nil  -- This stops execution and will not handle correctly.
getfenv     = nil  -- Disable this.
setfenv     = nil  -- Disable this.
_G          = nil  -- Carry no globals this way.
module 		= nil  -- Disable old global module functionality.
os.execute 	= nil  -- Disable this in case of badly secured servers or stupid CGI tricks.
dofile		= nil  -- Supposed to be using file.interpret for includes.

------------------------------------------------------ 
-- Parse a certain backend.
------------------------------------------------------
if pg.backend == 'CGI' or pg.backend == 'cgi' or not pg.backend then
	require("handlers.cgi-2")

elseif pg.backend == 'FCGI' or pg.backend == 'fcgi' then
	require("handlers.fcgi")

elseif pg.backend == 'WSAPI' or pg.backend == 'wsapi' then
	require("handlers.wsapi")

elseif pg.backend == 'CLI' or pg.backend == 'cli' then
	require("handlers.cli")
end
